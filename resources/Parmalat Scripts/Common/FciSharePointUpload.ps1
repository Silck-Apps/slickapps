# This script is provided "AS IS" with no warranties, and confers no rights.  
# Use of the script sample is subject to the terms specified at  
# Microsoft - Information on Terms of Use: http://www.microsoft.com/info/cpyright.htm  
 
[CmdletBinding(SupportsShouldProcess=$false)] 
 
param( 
    [parameter(Mandatory=$true, ParameterSetName="RecordsCenter")] 
    [switch] $useOfficialFileWebService, 
     
    [parameter(Mandatory=$true)] 
    [string] $file, 
 
    [parameter(Mandatory=$true)] 
    [string] $url, 
 
    [parameter(Mandatory=$true, ParameterSetName="Library")] 
    [string] $libPath, 
 
    [string] $name, 
     
    [parameter(ParameterSetName="RecordsCenter")] 
    [string] $contentType = "Document", 
 
    [ValidateSet("keep", "delete", "url")] 
    [string] $sourceAction = "keep", 
 
    [parameter(ParameterSetName="Library")] 
    [ValidateSet("overwrite", "skip", "fail")] 
    [string] $targetAction = "overwrite", 
 
    [ValidateSet("copy", "ignore")] 
    [string] $propertyAction = "copy", 
     
    [string] $user, 
    [string] $password, 
     
    [parameter(ParameterSetName="RecordsCenter")] 
    [switch] $additionalProperties 
    ) 
     
DynamicParam 
{ 
    if($PSCmdlet.ParameterSetName -ieq "RecordsCenter" -and $additionalProperties) 
    { 
        $paramName = "extraProps" 
         
        $attributes = New-Object -TypeName Management.Automation.ParameterAttribute 
        $attributes.ValueFromRemainingArguments = $true 
         
        $attributeCollection = New-Object -TypeName Collections.ObjectModel.Collection``1[System.Attribute] 
        $attributeCollection.Add($attributes) 
         
        $param = New-Object -TypeName Management.Automation.RuntimeDefinedParameter -ArgumentList ($paramName, [String[]], $attributeCollection) 
 
        $params = New-Object -TypeName Management.Automation.RuntimeDefinedParameterDictionary 
        $params.Add($paramName, $param) 
         
        $params 
    } 
} 
     
Process 
{ 
 
Set-StrictMode -Version latest 
 
 
function GetUrlSuffix 
{ 
    ".uploaded.url" 
} 
 
function IsUploadedFile 
{ 
    param( 
        [string] $name 
        ) 
         
    $suffix = GetUrlSuffix 
     
    $name.Length -ge $suffix.Length -and  
    [String]::Compare($name, $name.Length - $suffix.Length, $suffix, 0, $suffix.Length, $true) -eq 0 
} 
 
function CombineUrls 
{ 
    param( 
        [string] $a,  
        [string] $b 
        ) 
     
    if($a.length -eq 0) 
    { 
        return $b 
    } 
     
    if($b.length -eq 0) 
    { 
        return $a 
    } 
     
    $count = 0 
     
    if($a[$a.length - 1] -eq "/") 
    { 
        ++$count 
    } 
     
    if($b[0] -eq "/") 
    { 
        ++$count 
    } 
     
    switch($count) 
    { 
        0 
        { 
            return $a + "/" + $b 
        } 
 
        1 
        { 
            return $a + $b 
        } 
 
        2 
        { 
            return $a + $b.substring(1) 
        } 
    } 
} 
 
function GetUserNameAndDomain 
{ 
    param( 
        [string] $user 
        ) 
         
    $arr = $user.Split("\") 
     
    if($arr.Length -eq 2) 
    { 
        $arr[1], $arr[0] 
    } 
    else 
    { 
        $arr = $user.Split("@") 
 
        if($arr.Length -eq 2) 
        { 
            $arr[0], $arr[1] 
        } 
        else 
        { 
            $user, "" 
        } 
    } 
} 
 
function GetNetCredentials 
{ 
    param( 
        [string] $user, 
        [string] $password 
        ) 
 
    $cred = New-Object -TypeName Net.NetworkCredential 
    $cred.UserName, $cred.Domain = GetUserNameAndDomain $user 
    $cred.Password = $password 
     
    $cred 
} 
 
function GetPsCredentials 
{ 
    param( 
        [string] $user, 
        [string] $password 
        ) 
 
    $userName, $domain = GetUserNameAndDomain $user 
    $securePassword = ConvertTo-SecureString -AsPlainText -Force -String $password 
     
    New-Object -TypeName Management.Automation.PSCredential -ArgumentList ("$domain\$userName", $securePassword) 
} 
     
function GetWebService 
{ 
    param( 
        [string] $namespace, 
        [string] $type, 
        [string] $url, 
        [string] $user, 
        [string] $password 
        ) 
 
    # 
    # Try to create the object first as the namespace may be there already 
    # 
     
    try 
    { 
        $obj = New-Object -TypeName "$namespace.$type" 
    } 
    catch 
    { 
        # 
        # Create the proxy and try again. 
        # This should not require special permissions 
        # 
         
        if($user.length -ne 0 -and $password.length -ne 0) 
        { 
            $cred = GetPsCredentials $user $password 
            $obj = New-WebServiceProxy -Uri $url -Namespace $namespace -Credential $cred 
        } 
        else 
        { 
            $obj = New-WebServiceProxy -Uri $url -Namespace $namespace -UseDefaultCredential 
        } 
         
        if($obj -eq $null) 
        { 
            throw "Cannot create Web Proxy from ""$url""" 
        } 
    } 
     
    $obj.Url = $url 
 
    if($user.length -ne 0 -and $password.length -ne 0) 
    { 
        $obj.UseDefaultCredentials = $false 
        $obj.Credentials = GetNetCredentials $user $password 
    } 
    else 
    { 
        $obj.UseDefaultCredentials = $true 
    } 
         
    $obj 
} 
 
function TranslateProperty 
{ 
    param( 
        $prop, 
        $propDef, 
        [bool] $useOfficialFileWebService 
        ) 
 
    if($useOfficialFileWebService) 
    { 
        $field = New-Object -TypeName WssUpload.RecordsRepositoryProperty 
        $field.Name = $prop.Name 
        $field.Value = $prop.Value 
 
        switch($propDef.Type) 
        { 
            # 
            # FsrmPropertyDefinitionType_OrderedList 
            # 
            1 
            { 
                $field.Type = "Choice" 
            } 
             
            # 
            # FsrmPropertyDefinitionType_MultiChoiceList 
            # 
            2 
            { 
                $field.Type = "MultiChoice" 
 
                $field.Value = $prop.Value.Replace("|", ";#") 
            } 
             
            # 
            # FsrmPropertyDefinitionType_String 
            # 
            4 
            { 
                $field.Type = "Text" 
            } 
             
            # 
            # FsrmPropertyDefinitionType_MultiString 
            # 
            5 
            { 
                $field.Type = "Note" 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Int 
            # 
            6 
            { 
                $field.Type = "Number" 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Bool 
            # 
            7 
            { 
                $field.Type = "Boolean" 
                 
                switch($prop.Value) 
                { 
                    "0" 
                    { 
                        $field.Value = "False" 
                    } 
 
                    "1" 
                    { 
                        $field.Value = "True" 
                    } 
                } 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Date 
            # 
            8 
            { 
                $field.Type = "DateTime" 
                 
                # 
                # Convert to ISO8601 
                # 
                 
                $dateTime = [DateTime]::FromFileTimeUtc([Int64] $prop.Value) 
                $field.Value = $dateTime.ToString("o") 
            } 
        } 
    } 
    else 
    { 
        $field = New-Object -TypeName WssUpload.FieldInformation 
        $field.DisplayName = $prop.Name 
        $field.Value = $prop.Value 
 
        switch($propDef.Type) 
        { 
            # 
            # FsrmPropertyDefinitionType_OrderedList 
            # 
            1 
            { 
                $field.Type = [WssUpload.FieldType]::Choice 
            } 
             
            # 
            # FsrmPropertyDefinitionType_MultiChoiceList 
            # 
            2 
            { 
                $field.Type = [WssUpload.FieldType]::MultiChoice 
 
                $field.Value = $prop.Value.Replace("|", ";#") 
            } 
             
            # 
            # FsrmPropertyDefinitionType_String 
            # 
            4 
            { 
                $field.Type = [WssUpload.FieldType]::Text 
            } 
             
            # 
            # FsrmPropertyDefinitionType_MultiString 
            # 
            5 
            { 
                $field.Type = [WssUpload.FieldType]::Note 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Int 
            # 
            6 
            { 
                $field.Type = [WssUpload.FieldType]::Number 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Bool 
            # 
            7 
            { 
                $field.Type = [WssUpload.FieldType]::Boolean 
                 
                switch($prop.Value) 
                { 
                    "0" 
                    { 
                        $field.Value = "False" 
                    } 
 
                    "1" 
                    { 
                        $field.Value = "True" 
                    } 
                } 
            } 
             
            # 
            # FsrmPropertyDefinitionType_Date 
            # 
            8 
            { 
                $field.Type = [WssUpload.FieldType]::DateTime 
                 
                # 
                # Convert to ISO8601 
                # 
                 
                $dateTime = [DateTime]::FromFileTimeUtc([Int64] $prop.Value) 
                $field.Value = $dateTime.ToString("o") 
            } 
        } 
    }     
     
    $field 
} 
 
function ReadProperties 
{ 
    param( 
        [string] $fileName, 
        [bool] $useOfficialFileWebService 
        ) 
         
    $fields = @() 
 
    $fsrmMgr = New-Object -ComObject "Fsrm.FsrmClassificationManager" 
    $props = $fsrmMgr.EnumFileProperties($filename) 
     
    foreach($prop in $props) 
    { 
        try 
        { 
            $propDef = $fsrmMgr.GetPropertyDefinition($prop.Name) 
        } 
        catch 
        { 
            # 
            # Most probably not an FSRM property; just skip 
            # 
            continue 
        } 
         
 
        $fields += TranslateProperty $prop $propDef $useOfficialFileWebService 
    }     
     
    $fields 
} 
 
function CreatePropertiesFromArray 
{ 
    param( 
        [string[]] $props 
        ) 
     
    $fields = @() 
     
    for($i = 0; $i + 2 -lt $props.Length; $i += 3) 
    { 
        $field = New-Object -TypeName WssUpload.RecordsRepositoryProperty 
         
        $field.Name = $props[$i] 
        $field.Type = $props[$i + 1] 
        $field.Value = $props[$i + 2] 
         
        $fields += $field 
    } 
     
    $fields 
} 
 
function CreateUrl 
{ 
    param( 
        [string] $src, 
        [string] $dest 
        ) 
 
    $src += GetUrlSuffix 
     
    try 
    { 
        $writer = New-Object -TypeName IO.StreamWriter -ArgumentList $src 
        $writer.WriteLine("[InternetShortcut]") 
        $writer.WriteLine("URL=$dest") 
    } 
    finally 
    { 
        $writer.Dispose() 
    } 
} 
 
function UploadToLibrary 
{ 
    param( 
        [string] $file, 
        [string] $url, 
        [string] $libPath, 
        [string] $name, 
        [string] $sourceAction, 
        [string] $targetAction, 
        [string] $propertyAction, 
        [string] $user, 
        [string] $password 
        ) 
     
    # 
    # Skip previously uploaded files 
    # 
    if(IsUploadedFile $file) 
    { 
        return 
    } 
     
    if($name.Length -eq 0) 
    { 
        # 
        # No rename 
        # 
        $name = [IO.Path]::GetFileName($file) 
    } 
     
    $relPath = CombineUrls $libPath $name 
 
    if($targetAction -ine "overwrite") 
    { 
        # 
        # See if the target exists 
        # 
         
        $urlVer = CombineUrls $url "_vti_bin/versions.asmx" 
        $wsVersion = GetWebService "WssUpload" "Versions" $urlVer $user $password 
        $targetPresent = $true 
         
        try 
        { 
            $dummy = $wsVersion.Getversions($relPath) 
        } 
        catch 
        { 
            $targetPresent = $false 
        } 
         
        if($targetPresent) 
        { 
            if($targetAction -ieq "skip") 
            { 
                return 
            } 
             
            throw "Target file """ + $relPath + """ already exists" 
        } 
    } 
     
    $urlCopy = CombineUrls $url "_vti_bin/copy.asmx" 
    $wsCopy = GetWebService "WssUpload" "Copy" $urlCopy $user $password 
     
    $data = [IO.File]::ReadAllBytes($file) 
    $dest = @(CombineUrls $url $relPath) 
    $fields = @() 
     
    if($propertyAction -ieq "copy") 
    { 
        $fields = @(ReadProperties $file $false) 
    } 
     
    $results = $null 
    $ret = $wsCopy.CopyIntoItems(" ", $dest, $fields, $data, [ref] $results) 
     
    if($ret -ne 0) 
    { 
        throw "Copy request did not complete" 
    } 
     
    if($results[0].ErrorCode -ne 0) 
    { 
        throw $results[0].ErrorMessage 
    } 
     
    switch($sourceAction) 
    { 
        "delete" 
        { 
            [IO.File]::Delete($file) 
        } 
         
        "url" 
        { 
            [IO.File]::Delete($file) 
            CreateUrl $file $dest[0] 
        } 
    } 
} 
 
function UploadToRecordsCenter 
{ 
    param( 
        [string] $file, 
        [string] $url, 
        [string] $name, 
        [string] $recordRouting, 
        [string] $contentType, 
        [string[]] $extraProps, 
        [string] $sourceAction, 
        [string] $propertyAction, 
        [string] $user, 
        [string] $password 
        ) 
         
    # 
    # We need groups of three strings for additional properties: name, type, value 
    # 
    if($extraProps.Length % 3 -ne 0) 
    { 
        throw "Invalid number of additional property items" 
    } 
     
    # 
    # Skip previously uploaded files 
    # 
    if(IsUploadedFile $file) 
    { 
        return 
    } 
     
    if($name.Length -eq 0) 
    { 
        # 
        # No rename 
        # 
        $name = [IO.Path]::GetFileName($file) 
    } 
     
    $urlOfficialFile = CombineUrls $url "_vti_bin/officialfile.asmx" 
    $wsRepository = GetWebService "WssUpload" "RecordsRepository" $urlOfficialFile $user $password 
     
    $data = [IO.File]::ReadAllBytes($file) 
     
    # 
    # Prepare the properties array. Start with the required properties... 
    # 
    $fields = @(CreatePropertiesFromArray @( 
        "FileLeafRef", "Text", $name, 
        "ContentType", "Text", $contentType 
        )) 
     
    # 
    # ... then add FSRM properties if needed 
    # 
    if($propertyAction -ieq "copy") 
    { 
        $fields += @(ReadProperties $file $true) 
    } 
 
    # 
    # ... and finally add any extra properties passed in 
    #     
    $fields += @(CreatePropertiesFromArray $extraProps) 
 
    $userName, $domain = GetUserNameAndDomain $user 
     
    if($domain.length -ne 0) 
    { 
        $domain += "\" 
    } 
     
    $userName = "$domain$userName" 
     
    if($userName.Length -eq 0) 
    { 
        # 
        # We need to pass something here 
        # 
        $userName = " " 
    } 
     
    $res = $wsRepository.SubmitFile($data, $fields, $recordRouting, $name, $userName) 
     
    # 
    # Parse the result 
    # 
     
    $xmlDoc = New-Object -TypeName Xml.XmlDocument 
     
    # 
    # We need to wrap the XML result with a document element 
    # 
     
    $xmlDoc.LoadXml("<x>$res</x>") 
    $resultCode = "invalid response format" 
    $targetUrl = "" 
    $xmlNode = $xmlDoc.DocumentElement.SelectSingleNode("ResultCode") 
     
    if($xmlNode -ne $null) 
    { 
        if($xmlNode.InnerText -eq "Success") 
        { 
            $xmlNode = $xmlDoc.DocumentElement.SelectSingleNode("ResultUrl") 
             
            if($xmlNode -ne $null) 
            { 
                $targetUrl = $xmlNode.InnerText 
            } 
        } 
        else 
        { 
            $resultCode = $xmlNode.InnerText 
        } 
    } 
     
    if($targetUrl.Length -eq 0) 
    { 
        throw "Error submitting file: $resultCode" 
    } 
     
    switch($sourceAction) 
    { 
        "delete" 
        { 
            [IO.File]::Delete($file) 
        } 
         
        "url" 
        { 
            [IO.File]::Delete($file) 
            CreateUrl $file $targetUrl 
        } 
    } 
} 
 
try 
{ 
    if($PSCmdlet.ParameterSetName -ieq "Library") 
    { 
        UploadToLibrary $file $url $libPath $name $sourceAction $targetAction $propertyAction $user $password 
    } 
    else 
    { 
        $extraProps = $null 
         
        if(-not $PSCmdlet.MyInvocation.BoundParameters.TryGetValue("extraProps", [ref] $extraProps)) 
        { 
            $extraProps = @() 
        } 
         
        UploadToRecordsCenter $file $url $name $null $contentType $extraProps $sourceAction $propertyAction $user $password 
    } 
} 
catch 
{ 
    # 
    # TODO: Add logging 
    # 
 
    throw 
} 
 
} 
 
<# 
    .SYNOPSIS 
    Upload a file to a SharePoint library or content organizer. 
     
    .DESCRIPTION 
    The script uploads a file to a SharePoint document library or content organizer. Optionally, it also deletes the source file or replaces it with a shortcut to the uploaded item.  
    The source file is identified by its file system path. The SharePoint library is identified by the site URL and the relative path to the document library. The content organizer is only idendified by the site URL. 
    The uploaded document can have the same name as the source file or be given a different name. 
    Classification properties can either be propagated to the target or ignored. The target library should have a content type consistent with the classification properties. 
     
    .NOTES 
     
    Classification types are mapped to SharePoint content types as follows: 
     
        FsrmPropertyDefinitionType_OrderedList -> Choice 
        FsrmPropertyDefinitionType_MultiChoiceList -> MultiChoice 
        FsrmPropertyDefinitionType_String -> Single line of text 
        FsrmPropertyDefinitionType_MultiString -> Multiple lines of text 
        FsrmPropertyDefinitionType_Int -> Number 
        FsrmPropertyDefinitionType_Bool -> Boolean 
        FsrmPropertyDefinitionType_Date -> DateTime 
 
    This mapping may need changing according to how the target SharePoint content type is actually defined. 
     
    .PARAMETER useOfficialFileWebService 
    If specified, the file is uploaded to a content organizer by using the Official File Web service 
     
    .PARAMETER file 
    File system path to the file to be uploaded 
     
    .PARAMETER url 
    URL to the target SharePoint site 
     
    .PARAMETER libPath 
    Relative path to the target document library 
     
    .PARAMETER name 
    Target document name. If not specified, it defaults to the source file name. 
     
    .PARAMETER sourceAction 
    Specifies what to do with the source file after it is successfully uploaded. Can be one of: 
     
        keep    -leave the source file in place (default) 
        delete  -delete the source file 
        url     -create an Internet shortcut to the target document 
         
    .PARAMETER targetAction 
    Specifies how to handle existing target documents. Can be one of: 
     
        overwrite -overwrite any existing target with the source file (default) 
        skip      -do not upload the file and return success 
        fail      -do not upload the file and return error 
         
    .PARAMETER propertyAction 
    Specifies how to propagate classification properties from source to target. Can be one of: 
     
        copy   -copy classification properties of the source to the target (default) 
        ignore -do not copy classification properties, let target get default property values 
         
    .PARAMETER user 
        Specifies, togethter with "-password" parameter, the credentials to use for the operation. Can be in the form of "domain\user" or "user@domain". Ignored if "-password" is not specified. 
         
    .PARAMETER password 
        Specifies, togethter with "-user" parameter, the credentials to use for the operation. Ignored if "-user" is not specified. 
         
    .EXAMPLE 
     
    FciSharePointUpload.ps1 -file c:\docs\foo.docx -url http://sharepoint/sites/foo -libPath "Shared Documents" 
 
    Uploads a file with no rename using default credentials. 
         
    .EXAMPLE 
     
    FciSharePointUpload.ps1 -file c:\docs\foo.docx -url http://sharepoint/sites/foo -libPath "Shared Documents" -name bar.docx -user "mydomain\myuser" -password "mypassword" 
         
    Uploads a file with a different name using explicit credentials. 
 
    .EXAMPLE 
     
    FciSharePointUpload.ps1 -file c:\docs\foo.docx -url http://sharepoint/sites/foo -libPath "Shared Documents" -sourceAction url -targetAction skip -propertyAction ignore 
 
    Uploads a file if not already present with default properties and replaces the source with an Internet shortcut. 
     
    .EXAMPLE 
     
    FciSharePointUpload.ps1 -useOfficialFileWebService -file c:\docs\foo.docx -url http://sharepoint/sites/foo 
     
    Uploads a file to a content organizer site. 
#> 
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbnysx0Sm7jV7s4XhJoB9XlsP
# jASgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMTAzMzAwOTI5MDFaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAstvPQlH8A8DC
# aG6+9LF36Tt/L2J688VvOCke3uk+t8FodbdyXxlbquvSY/MlDdcFqLH+OfqLgzNx
# d+BeK2QztSXFz3NQk4kQpRP+1zLoRS3c+aqtGhFqBjHgIfPyNnxRsKfEXYBU3qom
# F4Bk9NyY+3CTLawBo8H1Ax+ElvXeUr0CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQPZsRUcVga4udzeiCRmAx+qEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQzSRonynqmIxBzppu
# 23W7JTAJBgUrDgMCHQUAA4GBAAAf0SuTy3hVb3iIEithtMJSEs63ls9gFNjIwWjP
# X4lVbtzxVuZ1rCgHQecyhIkgRUctosut5ZH+FFz4TSb8ymuMDOZkUD6MVWmWsfbb
# ZSzBtysvo07bRpYn/fKhVG8Hlgl1LzZ1R6HZoSwT70MAldZLFMQce597zoWoHGqw
# 7ANeMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEO2z+06FYpiIRBwl74emOSIwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FC900FCg3fuNzgtipxOFWmUID14yMA0GCSqGSIb3DQEBAQUABIGAY+aIiaKE8uAW
# vHzq3NUBcEnCMd5M5BlUHEMJhrOenSOqWiEnBqbOl/aRSgl3VJAwaCbTtYKTymFN
# 8OTSByuzW8t9Q0EiDAlb6qK5K1X2bhCa3yV9vtvJ8KmnX4et5GNDBc/0Zw07Okzm
# owYJOmwkAlYnLpfEoOFwmV6+gm4iK2U=
# SIG # End signature block
