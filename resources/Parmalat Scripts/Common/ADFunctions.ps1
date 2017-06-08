Function Add-Snapins {

$Snapins = Get-PSSnapin
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'Microsoft.Exchange.Management.PowerShell.Admin') {$match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin}
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'quest.activeroles.admanagement') {$Match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin quest.activeroles.admanagement}

}
########## Create and validate UserName ###################
function func_CreateUserName {
	Param ($LastName, $FirstName, $DC, $DisplayName = $null)
	if ($LastName -notlike $null) {
		$LastName = $($LastName.replace("'","")).tolower()
		$LastName = $LastName.replace(" ","")
	}
	if ($FirstName -notlike $null) {
		$FirstName = $($FirstName.replace("'","")).ToLower()
		$FirstName = $FirstName.replace(" ","")
	}
	if ($DisplayName -notlike $null) {
		$DisplayName = $($DisplayName.replace("'","")).ToLower()
		$DisplayName = $DisplayName.replace(" ","")
		$DisplayName = $DisplayName.replace(",","")
	}
	if ($DisplayName -notlike $null) {$strUserName = $DisplayName}
	else {$strUserName = $LastName + $FirstName.SubString(0,1)}
	$i = 1
	Do {
	$objUsr = $null
	If ((Get-ADUser -LDAPFilter "(SAMAccountName=$strUserName)") -ne $null) {
		$objUsr = Get-ADUser -Server $DC -Identity $strUserName}
	if ($DisplayName -notlike $null) {$newname = $DisplayName + $i}
	else {$newname = $LastName + $i + $FirstName.SubString(0,1)}
	If ($objUsr -ne $null){$strUserName = $newname}
	$i++
	}
	Until ($objUsr -eq $null)
	Return $strUserName
}
###### Copy User to be same as and return group membership ######
function func_CopyUser {
Param ($UsrDN)
$strParentOU = $null
$PathComps = $UsrDN.Split(",")
For ($i = 2; $i -lt $PathComps.count; $i++) {$strParentOU = $strParentOU + "," + $PathComps[$i]}
$strParentOU = $strParentOU.Trim(",")
$strParentOU = [ADSI]("LDAP://" + $strParentOU)
$strOUName = $PathComps[0] + "," + $PathComps[1]
########### copy User Group MemberShip
$objCPUsr = $strParentOU.psbase.children.find($strOUName)
$groups = $objCPUsr.Memberof
Return $groups
}
#   Removes given user from AD supply the Remove FOlders switch to delete M drive and profile folders
Function func_RemoveUser {Param ($UserName, [Switch]$RemoveFolders, $HomePath, $ProfilePath, $DC, $FS)     
	Trap {$HTMLBody = $HTMLBody  + $_.Exception.Message + "<BR>" + `
		'Script Line Number: ' + $SPAN_Bold + $_.InvocationInfo.scriptlinenumber + "</SPAN><BR>" + `
		'Command: ' + $SPAN_Bold + $_.InvocationInfo.MyCommand.Name + "</SPAN><BR><BR>"
	$HTMLBody | Out-File -FilePath $strLogFile -Append -NoClobber
	}
	$User = $null
	$str = $HomePath.Trim("\")
	$folder = $str.Split("\")
	$LogRb_ErrHomeDir = $SPAN_Bold + '"' + $HomePath + '"</SPAN> not found so it wasn''t deleted<BR>'
	$LogRb_ErrProfDir = $SPAN_Bold + '"' + $ProfilePath + '"</SPAN> not found so it wasn''t deleted<BR>'
	$LogRb_ErrDelUser = $SPan_BoldRed + 'Unable to Remove User: "' + $UserName + '"</SPAN><BR>'
	$LogRb_DelADUser = 'Active Directory Account ' + $SPAN_Bold + '"' + $UserName + '"</SPAN> has been deleted<BR>'
	$LogRb_DelShare = 'Attempting to Remove Share Name "' + $folder[2] + '$ - '
	$LogRb_DelHomePath = $SPAN_Bold + '"' + $HomePath + '"</SPAN> has been deleted.<BR>'
	$LogRb_DelProfDir = $SPAN_Bold + '"' + $ProfilePath + '"</SPAN> has been deleted.<BR>'
	$Path = '\\' + $folder[0] + '\' + $folder[2]+ '$'
	$Log_Header = $H2 + 'User Name: ' + $UserName + '<BR>' + `
		'M Drive Location: <A HREF="' + $Path + '">' + $Path + '</A></P>'
	$filter = "Name='\\\\" + $folder[0] + '\\' + $folder[2] + "$'"
	$HTMLBody = $HTMLBody + $Log_Header
	Remove-ADUser -Identity $UserName -Server $DC
	IF ($($Error[0].invocationinfo.mycommand).name -eq "Remove-ADUser"){
		$HTMLBodyactions = $LogRb_ErrDelUser}
	Else {$HTMLBodyactions = $LogRb_DelADUser}
	If ($RemoveFolders -eq $true){
		$HTMLBodyActions = $HTMLBodyactions + $LogRb_DelShare
		$objShare = gwmi -Class Win32_Share -ComputerName $FS -Filter $filter
		If ($objShare -ne $null){$Result = $objShare.Delete()}
		$strResult = func_Win32_ShareReturnValue $Result.ReturnValue
		IF ($Result.ReturnValue -eq 0){$HTMLBodyActions = $HTMLBodyActions + $Span_Bold + $strResult + '</SPAN><BR>'}
		Else {$HTMLBodyActions = $HTMLBodyActions + $Span_BoldRed + $strResult + '</SPAN><BR>'}
		If ((Test-Path $HomePath) -eq $true) {Remove-Item -Path $HomePath -Force
			$HTMLBodyActions = $HTMLBodyActions + $LogRb_DelHomePath}
		Else {Throw $LogRb_ErrHomeDir}
		If ((Test-Path $strProfileDir) -eq $true) {Remove-Item -Path $strProfileDir -Force
		$HTMLBodyActions = $HTMLBodyActions + $LogRb_DelProfDir}
		Else {Throw $LogRb_ErrProfDir}
	}
	Return $HTMLBodyActions
}
Function ParseADUsers {$AllUsers = $null
$strFilter = "(&(objectCategory=User))"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://OU=Parmalat Users,DC=Parma,DC=Internal")
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"
$colProplist = @("name","SAMAccountName")
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}
$colResults = $objSearcher.FindAll()
Return $colResults}

###########################################   validate an delete obsolete objects ####################

Function ValidateADUser {Param ($credentials, $jobnumber, $name, $fn, $sn, $employeeID, $CC, $PALOU = "OU=Parmalat Users,DC=Parma,DC=Internal",$SAP2ADOU = $("OU=SAP2AD Links Only," + $PALOU), $LogFile,
	$filterstrings = @($("(name=*" + $name + "*)(objectClass=Person)"),$("(name=*" + $sn + "*" + $fn + "*)(objectClass=Person)"),`
									$("(name=*" + $fn + "*" + $sn + "*)(objectClass=Person)")))
	if ($employeeID -gt 0) {$filterstrings += $("(employeeID=" + $employeeID + ")(objectClass=Person)")}
	$deletefromOUs = @("Custom Recipients","SAP2AD Links Only","Performalat")	
	$Halt = $false
	$CustomRecipientsOU = "LDAP://*OU=Custom Recipients," + $PALOU
	$SAP2ADOU = "LDAP://*OU=SAP2AD Links Only," + $PALOU
	$SMSContactsOU = "LDAP://*OU=SMS Contacts,OU=Custom Recipients," + $PALOU
	$PerformalatOU = "LDAP://*OU=Performalat," + $PALOU
	function cleanlist {Param ($list)
		$cleanlist = @()
		foreach ($obj in $list) {
			if ($obj -ne 0) {$cleanlist += $obj}
			}
		$cleanlist = $cleanlist | Sort-Object -Property distinguishedName -Unique
		Return $cleanlist
	}
	$logstring = @"
User Object Validatiion Results......


"@

	foreach ($string in $filterstrings) {$matches += @(ParseParmalatUsersADSI -filterstring $string -searchbaseDN $PALOU)}
	if ($employeeID -gt 0) {
		$obj = get-qadobject -Identity $("EID_" + $employeeID) -SearchRoot $SAP2ADOU -SearchScope Subtree
		if ($obj -notlike $null) {
			$matches += ParseParmalatUsersADSI -filterstring $("(SAMAccountName=EID_" + $employeeID + ")(objectClass=Person)")
		}
	
	}
	$matches = cleanlist $matches
	$list = $null
	foreach ($match in $matches) {
		Switch -wildcard ($match.Parent) {
			$CustomRecipientsOU {

				if (($match.Parent.tostring() -like $SMSContactsOU) -and `
						($(Get-QADObject $match.distinguishedName.tostring()).memberof -notlike $null)) {
					$SMSCustomRecipients += @($match)
				}
				else {
				############################ set force switch here too......
					Remove-QADObject -Identity $match.distinguishedName.toString()
					$deletedCustomRecipients += @($match)
				}
			}
			$SAP2ADOU {
				$DeleteObjects += @($match)
				$SAP2AD += @($match)
			}
			$PerformalatOU {
				$DeleteObjects += @($match)
				$Performalat += @($match)
			}
			default {if ($match -ne $null) {
				$UserAccounts += @($match)
				$Halt = $true}}
			}
		}
		if ($DeleteObjects -ne $null) {
		foreach ($object in $DeleteObjects) {if ($object.employeeID.tostring() -like $employeeID) {
######   Set the force switch here
			Remove-QADObject -Identity $object.distinguishedname.tostring() -force; $IDmatched += @($object)}
			else {$nomatch += @($object)}
		}
		}

	if ($($deletedCustomRecipients.count + $SMSCustomRecipients.count) -gt 0) {
	$logstring += @"
$($deletedCustomRecipients.count + $SMSCustomRecipients.count) Custom Recipients found.

"@
		if ($deletedCustomRecipients.count -gt 0) {$logstring += @"
$($deletedCustomrecipients.count) Custom Recipients were removed.....
$($deletedCustomRecipients | ft name,distinguishedName -AutoSize | out-string)
"@
		}
		if ($SMSCustomRecipients.count -gt 0) {$logstring += @"
$($SMSCustomRecipients.count) Active SMS numbers found. These WERE NOT removed.....
$($SMSCustomRecipients | ft name,distinguishedName -AutoSize | out-string)
"@
		}
	}
	
	else {$logstring += @"
0 Custom Recipients Found

"@
	}
	if ($SAP2AD.count -gt 0) {
	$logstring += @"
$($SAP2AD.count) Accounts found in the "SAP2AD Links Only" OU
$($SAP2AD | ft employeeID,name,distinguishedname -autosize | out-string)
"@
	}
	else {$logstring += @"
0 Accounts found in the "SAP2AD Links Only" OU

"@
	}
	if ($Performalat.count -gt 0) {
	$logstring += @"
$($Performalat.count) Accounts found in the "Performalat" OU
$($Performalat | ft employeeID,name,distinguishedname -autosize | out-string)
"@
	}
	else {$logstring += @"
0 Accounts found in the "Performalat" OU	

"@
	}
	if ($IDmatched.count -gt 0) {
		$logstring += @"
These user accounts (all found in the "Performalat" or "SAP2AD Links Only" OUs) have matching employee IDs of "$employeeID" and were removed.
$($IDmatched | ft name,distinguishedname -autosize | out-string)
"@
	}
	if ($nomatch.count -gt 0) {
		$logstring += @"
These accounts (also found in the "SAP2AD Links Only" or "Performalat OUs) DID NOT have matching employee ID numbers and were left alone.....
$($nomatch | ft employeeID,name,distinguishedname -autosize | out-string)
"@
	}
	if ($UserAccounts.count -gt 0) {
		$logstring += @"

******   User Validation Failed   ******
$($UserAccounts.count) Authentic User account(s) detected!! 
$($UserAccounts | ft employeeID,name,distinguishedname -autosize | out-string)
"@
	Write-EventLog -EntryType Warning -EventId 1 -LogName $LogFile -Message $logstring -Source "Validate-ADUser"
	}
	else {$logstring += @"

*********** User Validation Passed   ***************
No User account found with this person's details.
"@
#	Write-EventLog -EntryType Information -EventId 1 -LogName $LogFile -Message $logstring -Source "Validate-ADUser"
	}
	$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
	Write-EventLog -EntryType Information -EventId 1 -LogName $LogFile -Message $logstring -Source "Validate-ADUser"
	Return $Halt
}
############################################################################################################

Function ParseParmalatUsersADSI {Param($AllUsers = $null, $searchbaseDN = "OU=Parmalat Users,DC=Parma,DC=Internal", `
						$filterstring = "(objectCategory=Person)")
$strFilter = "(&" + $filterstring + ")"
$objDomain = New-Object System.DirectoryServices.DirectoryEntry($("LDAP://" + $searchbaseDN))
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"
#$colProplist = @("name","SAMAccountName","objectCategory","type","objectClass","employeeID","employeeNumber","DepartmentNumber","distinguishedName","Parent")
$colProplist = $null
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}
$colResults = $objSearcher.FindAll()
$users = @()

foreach ($usr in $colResults) {$users += [ADSI]$usr.path | select -Property "name","givenname","sn","SAMAccountName","objectCategory","type","objectClass","employeeID","employeeNumber","DepartmentNumber","distinguishedName","Parent","CanonicalName"}
Return $users}

Function ListGroups { Param ([Switch]$DistributionGroups, [Switch]$SecurityGroups, $Groups = $null)
	If ($groups -eq $null) {Throw 'No "Groups" parameter specified'}
	$reqswitches = $false
	If ($DistributionGroups.IsPresent -eq $true) {$reqswitches = $true}
	If ($SecurityGroups.IsPresent -eq $true) {$reqswitches = $true}
	If ($reqswitches -eq $false) {Throw 'Must Supply either "-DistributionGroups" or "-SecurityGroups" switch'}
	$Distgrps = @()
	$Secgrps = @()
	forEach ($grp in $groups) {
		$Type = $grp.Split(',')
		$Type = $Type[$($Type.count - 4)]
		$Type = $Type.substring(3,($Type.Length - 3))
		If ($Type -like 'Distribution Groups') {$Distgrps += $(Get-ADGroup -Identity $grp).name}
		Else {$Secgrps += $(Get-ADGroup -Identity $grp).name}
	}
	If ($DistributionGroups.IsPresent -eq $true) {$list = $Distgrps}
	If ($SecurityGroups.IsPresent -eq $true) {$list = $Secgrps}
	Return $list
}

Function Compare-ADGroupMembership { Param ($Group, $names)
# Group is the AD group to get the current list from
# names is a PSObject with the Displayname, SAMaccountName and SID properties included
	$users = @()
	$matches = @()
	$grouponly = @()
	$listonly = @()
	foreach ($usr in $(Get-QADGroup $Group).members) {$users += Get-QADObject $usr}
	$differences = Compare-Object -ReferenceObject $users -DifferenceObject $names -IncludeEqual
	foreach ($rec in $differences) {
		Switch ($rec.Sideindicator) {
			"==" {$matches += $rec.InputObject}
			"=>" {$listonly += $rec.InputObject}
			"<=" {$grouponly += $rec.InputObject}
		}
	}
	
	Return $matches, $listonly, $Grouponly
}
Function Validate-ADEmailAddress {Param ($Address = $null)
	$matches = Get-QADObject -LdapFilter "(mail=$Address)"
	if ($matches -like $null) {$matches = "NoMatches"}
	
	
	Return $matches
}


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIQaeVlStId5N+xh7niyCm+cW
# FPygggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FNlWgP8YtbRPnnNKl63SaZ8k9/EvMA0GCSqGSIb3DQEBAQUABIGAfAXCXkRE/Fqn
# QEtTG8Lffdv3bkkx9wwAi0KTM1994IsQtIXhMGxWgKgLlHo3u2jNeWp5q73n7SPj
# AIY6iOaT1JmVhi5Ban6xRQyg14BtMIVv1rJi0A+2AtDSg+BVb6pPV9H5tQIeLUJi
# +duUQdKmud7fs25GiA4B2f7wvDH7Vg0=
# SIG # End signature block
