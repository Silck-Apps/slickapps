Function Notify_Errors {Param($Body,$Subject,$ErrorSubject,$Attach)
	$HTMLBody = $HTMLBody + $Body
	ForEach ($entry in $error) {$HTMLBody = $HTMLBody + `
		$H2 + 'Error details</P>' + `
		'Message: ' + $entry + '<BR>' + `
		'Script File: ' + $entry.InvocationInfo.scriptName + '<BR>' + `
		'Script Line: ' + $entry.InvocationInfo.ScriptLineNumber + '<BR>' + `
		'Command: ' + $entry.InvocationInfo.MyCommand}
	$HTMLBody = $HTMLBody + $Log_EndEntry
	$Msg = CreateMsg -Body $HTMLBody -From $EmailFrom -Subject $ErrorSubject -To $EmailTo -Important
Return $Msg
}
Function Get-SpecialFolders {
	$SpecialFolders = [System.Enum]::GetValues([System.Environment+SpecialFolder])
	$FolderPaths = @()
	ForEach ($FolderName in $SpecialFolders) {$FolderPaths += [System.Environment]::GetFolderPath($FolderName)}
	$i = 0
	$here = @'
'@
	$props = @()
	ForEach ($Name in $SpecialFolders){
	If ($Name -notlike 'MyComputer') {
		$exists = $false
		$newpath = $($FolderPaths[$i].ToString()).Replace('\','\\')
		If ($i -eq 0) {$props += $Name.ToString(); $here += $Name.ToString() + ' = ' + $newpath + '
	'}
	Else {ForEach ($prop in $props) {If ($name.toString() -eq $prop) {$exists = $true; break}}
	If ($Exists -eq $false){$props += $name.tostring()
		$here += $name.toString() + ' = ' + $newpath + '
'}
		}
	}
	$i ++
	}
	$Hash = ConvertFrom-StringData $here
	$obj = New-Object -TypeName PSObject -Property $Hash
	Return $obj
}
Function ProcessList {Param ($string)
If ((select-string -InputObject $string  -pattern '","') -ne $null) {
	$list = $string.Replace('","','~').Trim('"').Split('~')
#	$i = 0
#	Do {$entries[$i] = $entries[$i].trim('"'); $i ++}
#	While ($i -lt $entries.count)
	}
Else {$list  = $string}
Return $list
}
Function Get-SiteAddress {Param ($Site,$DataSource = '\\parma.internal\dfsroot\gbs\helpdesk\scripts\PowerShellData.xls',$ExcelExists = $(test-ExcelExists -servername $env:COMPUTERNAME))
	if ($ExcelExists -eq $false) {$WS = Read-SpreadSheetOLE -filePath $DataSource -SheetName 'SiteAddresses'}
	else {$WS = Read-SpreadSheetExcel -filePath $DataSource -SheetName 'SiteAddresses'}
	$RowCount = $WS.Count
	$Row = $null
	For ($i = 0; $i -le $RowCount; $i++ ) {If ($WS[$i].SiteName -like $Site){$Row = $i; break}}
	If ($Row -ne $null) {$Address = New-Object -TypeName PSObject -Property @{
		Street = $WS[$Row].Street
		Suburb = $WS[$row].Suburb
		State= $WS[$row].State
		PostCode = $WS[$row].PostCode}
	}
	Else {$Address = $null}
	Return $Address
}
Function Get-SiteDataStoreDetails {Param ($Site,$DataSource = '\\parma.internal\dfsroot\gbs\helpdesk\scripts\PowerShellData.xls',$ExcelExists = $(test-ExcelExists -servername $env:COMPUTERNAME))
	if ($ExcelExists -eq $false) {$WS = Read-SpreadSheetOLE -filePath $DataSource -SheetName 'DataStores'}
	else {$WS = Read-SpreadSheetExcel -filePath $DataSource -SheetName 'DataStores'}
	$RowCount = $WS.Count
	$Row =$null
	For ($i = 0; $i -le $RowCount; $i++) {If ($WS[$i].SiteName -like $Site){$Row = $i; break}}
	If ($Row -ne $null){$DataStore = New-Object -TypeName PSObject -Property @{
		SubNet = $WS[$Row].SubNet
		DC = $WS[$row].DC
		FS = $WS[$row].FS
		UserDir = $WS[$row].UserDir
		ExDS = $WS[$row].ExDS}
	}
	Else {$DataStore = $null}
	Return $DataStore
}
function Open-WorkSheet {Param ($SheetName, $SourceFile)
$Global:objExcel = New-Object -ComObject Excel.Application
$objExcel.displayalerts=$False
$Global:objWorkBook = $objExcel.Workbooks.Open($SourceFile)
$intSheetCount = $objExcel.Worksheets.Count
$i = 1
Do {
	$objWorkSheet = $objWorkbook.Worksheets.Item($i)
	If ($SheetName -notmatch $objWorkSheet.Name)
		{
		$i++
		}
	If ($i -gt $intSheetCount)
		{$objExcel.Quit()
		Release-Ref($msg) > $null
		Release-Ref($objWorkSheet) > $null
		Release-Ref($objWorkBook) > $null
		Release-Ref($objExcel) > $null
		Throw 'Spread sheet name "' + $SheetName + '" does not exist.'
		}
	}
Until ($SheetName -match $objWorkSheet.name)

Return $objWorkSheet
}
Function Get-Function ($pattern, $path="Y:\Common") {            

 $parser  = [System.Management.Automation.PSParser]            

 Get-ChildItem $path -Recurse -Include *.ps1, *.psm1 | ForEach {             

   $content = [IO.File]::ReadAllText($_.FullName)
   $tokens  = $parser::Tokenize($content, [ref] $null)
   $count   = $tokens.Count             

   $(
       for($idx=0; $idx -lt $count; $idx += 1) {
            if($tokens[$idx].Content -eq 'function') {
                $targetToken = $tokens[$idx+1]
                New-Object PSObject -Property @{
                   FileName = $_.FullName
                   FunctionName = $targetToken.Content
                   Line = $targetToken.StartLine
                } | Select FunctionName, FileName, Line
            }
       }
   ) | Where {$_.FunctionName -match $pattern}
 }
}
Function Get-GroupMembersRecursively {Param ($ObjectName = $null)

If ($ObjectName -eq $null) {Throw "No Oject Name Supplied."}

$ObjectName = ProcessList $ObjectName

$list = @()
foreach ($Object in $ObjectName) {
	$item = Get-QADObject $Object
	$members = $Item.Member
	$members += $Item.NestedMembers
	$Members = Sort-Object -InputObject $members -Unique
	foreach ($entry in $members) {
		$entry = get-qadobject $entry
		If ($entry.type -like 'user') {$list += $entry}
	}
	$list = $list | Sort-Object -Unique -Property $_.sid
}
Return $list
}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSchcFudLUWXKGn6RYvpBV8Oh
# 00qgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FCd5QEqsV9RCSJRg20AKeHFvpe0/MA0GCSqGSIb3DQEBAQUABIGABCgSfNy+D+Tl
# SRKSFDDdw+TXCVXSihTqPKllpN/AhkSEoQQuG4d+aDzlcI69HUSbzs9FXkRQbn9e
# 3xJIvISo9AcKvy3gVIXzGzjSCSSokpDZoZdv46DBQYKfCQq30GRp7TZ6npVMg1Uo
# INkWpyFtM0qdmkAaWgnWMgKg9mB2rYE=
# SIG # End signature block
