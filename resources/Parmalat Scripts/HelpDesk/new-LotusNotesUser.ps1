#initalize script
Clear-Host
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\PowerShell.ps1')
. ($SysDir + '\vbfunctions.ps1')
. ($SysDir + '\SecurityFunctions.ps1')

$Snapins = Get-PSSnapin
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'Quest.ActiveRoles.ADManagement') {$match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin Quest.ActiveRoles.ADManagement}

#Error Messages
$errmsg = "The following item already exists: "
$errnoID = "This user does not have a Lotus Notes ID file. Exiting......."
$errbothnames = "Please supply both first and last names"
$errNoMDrive = "User M drive path dosen't exist. Exiting"
$errNoUser = "User account not found"
$errNoProfile = "User has no PS4 Profile. Create a PS4 profile by logging into Special Apps server before continuing."

# User Details
$firstname = inputbox -Prompt "Enter the user's First Name" -title "New Lotus Notes User - First Name"
$lastname = inputbox -Prompt "Enter the user's Last Name" -title "New Lotus Notes User - Last Name"
$items = processlist $('"' + $firstname + '","' + $lastname + '"')
foreach ($Item in $items) {If ($Item -like $null) {Throw $errbothnames}}
$initial = $firstname.substring(0,1)
$username = $lastname + $initial
$lotususername = $initial + $lastname
if ($lotususername.Length -gt 8) {$lotususername = $lotususername.Substring(0,8)}
$UserAccount = Get-QADUser -Identity $username
$UserHomeDir = $UserAccount.HomeDirectory
$profilePath = $useraccount.TsProfilePath

if ($UserHomeDir -like $null) {Throw $errNoUser}
if ($(test-path $UserHomeDir) -eq $false) {Throw $errNoMDrive}
$UserNotes7DataDir = $UserHomeDir + '\notes7\data'
$UserWinDir = $UserHomeDir + '\windows\'
$UserDesktop = $UserHomeDir + '\Desktop\'

# Source Data
$HelpDeskFolder = '\\parma.internal\dfsroot\GBS\HelpDesk\'
$NotesIDs = '\\parma.internal\dfsit\NotesIDs\'
$DataPath = $HelpDeskFolder + 'Scripts\LotusNotesData\'
$notes7Folder = $DataPath + 'notes7'
$inifile = $DataPath + 'notes.ini'
$IDPath = $NotesIDs + $lotususername + '.id'
$items = processlist $('"' + $UserNotes7DataDir + '","' + $($UserWinDir + 'notes.ini') + '"')

If ($(Test-Path $IDPath) -eq $false) {Throw $errnoID}
#If ($(Test-Path $ProfilePath) -eq $false) {Throw $errNoProfile}
If ($(Test-Path $ProfilePath) -eq $false) {
	New-Item -ItemType directory -Path $profilePath
	Copy-Item -Path $($DataPath + "Default User\*") -Destination $ProfilePath -Recurse -Force
	SetPermissions -homePath $profilePath.Replace('\win2k3','') -UserName $username
	}
foreach ($item in $items) {
	If ($(Test-Path $item) ) {Throw $($errmsg + $item)}
}

Add-QADGroupMember -Identity "Citrix Notes7 Users" -Member $username
Copy-Item -Path $notes7Folder -Destination $UserHomeDir -Recurse
Copy-Item -Path $inifile -Destination $UserWinDir
Copy-Item -Path $IDPath -Destination $UserNotes7DataDir
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiu+njq8NmamKfNI2aYWRhj4g
# +u+gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FFehuYTa8cEgfDaZVW6on798qHT/MA0GCSqGSIb3DQEBAQUABIGAOHuHeo237/7P
# 1S5H3KYbaBX6+qRj+qbOSGkLNs9K4Rx1OUyQd2+Y/nBpb2rZXpsW7jDjzvUCOgYv
# 3HmpnFHlT7rJeNpejBFQXBK2Y9TOfo+MWL4OEuBPVehyXlurs9FfQrkhHI8nI+To
# 7mgDByqoJjNiGeVx4zDmKa8npW2UsgQ=
# SIG # End signature block
