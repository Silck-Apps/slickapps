Param ([Switch]$Change, [Switch]$Save,
	$CopyUser = $null,
	$EditUser = $null)
. '\\parma.internal\dfsroot\GBS\HelpDesk\Scripts\Functions.ps1'
Clear-Host
Import-Module activedirectory
Trap {Write-Host $_.Exception.Message
	Write-Host ('Script Line Number: ' + $_.Invocationinfo.ScriptLineNumber)
	Write-Host ('Command: ' + $_.InvocationInfo.invocationname)
	Switch ($_.CategoryInfo.Category){
		'OperationStopped' {Exit}
		Default {Continue}
	}
}
#$CopyUser = Inputbox -Prompt 'Please Enter User to Copy...' -title 'Copy Group Membership'
If ($CopyUser -eq $null) {Throw '-CopyUser: A User Name Must be entered!'}
$match = validateADUser $CopyUser
If ($match -eq $false) {Throw 'User Name not found inActive Directory. Please check and try again.'}
#Write-Host 'What do you want to do?'
#Write-Host '(C)hange User access, (S)ave a list or (E)xit'
#$key = $host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
#Write-host "	You Selected: $($Key.character)"
#Start-Sleep 2
$CopyUser = Get-ADUser -Identity $CopyUser
$groups = func_copyuser $CopyUser.DistinguishedName
If ($Change.IsPresent -eq $true) {
	If ($EditUser -eq $null) {Throw '-EditUser: A User Name Must Be Entered!'}
	$match = validateADuser $EditUser
	If ($match -eq $false) {Throw 'User Name not found in Active Directory. Please check and try again.'}
	$EditUser = Get-ADUser -Identity $EditUser
	$oldgrps = func_copyuser $EditUser.DistinguishedName
	Write-Host 'Removing old groups....'
	Write-Host ''
	ForEach ($grp in $oldgrps) {Write-Host $(Get-ADGroup -Identity $grp).name
		Remove-ADGroupMember -Identity $grp -Members $EditUser.SAMAccountName}
	Write-Host ''
	Write-Host 'Ading New groups...'
	Write-Host ''
	ForEach ($grp in $groups) {Write-Host $(Get-ADGroup -Debug $grp).name
		Add-ADGroupMember -Identity $grp -Members $EditUser.SAMACcountName}
}
If ($Save.IsPresent -eq $true) {
	If ($Change.IsPresent -eq $true) {
		$names = @()
		ForEach ($grp in $groups) {$names += $(Get-ADGroup -Identity $grp).name}
		$output = @()
		$output += 'User Being Copied: ' + $CopyUser.SamAccountName
		$output += $names
	}
	$names = @()
	ForEach ($grp in $groups) {$names += $(Get-ADGroup -Identity $grp).name}
	$File = SaveFIleAs -Filter 'Text Files (*.txt)|*.txt*|All Files (*.*)| *.*' `
		-InitialDirectory $env:TEMP -Title 'Save File...' -FileName 'groups.txt'
	Out-File -FilePath $File[1] -InputObject $names
}
Switch ($key.character) {
	'C' {$EditUser = Inputbox -Prompt 'Enter Username to modify...' -title 'Enter User Name'
		$EditUser = Get-ADUser -Identity $EditUser
		$oldgrps = func_copyuser $EditUser.DistinguishedName
		Write-Host 'Removing old groups....'
		Write-Host ''
		ForEach ($grp in $oldgrps) {Write-Host $(Get-ADGroup -Identity $grp).name
			Remove-ADGroupMember -Identity $grp -Members $EditUser.SAMAccountName}
		Write-Host ''
		Write-Host 'Ading New groups...'
		Write-Host ''
		ForEach ($grp in $groups) {Write-Host $(Get-ADGroup -Debug $grp).name
			Add-ADGroupMember -Identity $grp -Members $EditUser.SAMACcountName}}
	'S' {$names = @()
		ForEach ($grp in $groups) {$names += $(Get-ADGroup -Identity $grp).name}
		$File = SaveFIleAs -Filter 'Text Files (*.txt)|*.txt*|All Files (*.*)| *.*' `
			-InitialDirectory $env:TEMP -Title 'Save File...' -FileName 'groups.txt'
		Out-File -FilePath $File[1] -InputObject $names}
	'E' {Exit}
	default {Write-Host ('Error! ' + $key.character + ' is invalid!') -BackgroundColor Red}
	}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUPdKwHVsGYXUTEZzJcod4Ndh
# +sWgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FBtsAl5HniCusuY++aajNPor0ly5MA0GCSqGSIb3DQEBAQUABIGAa7bWxs4v8JD7
# 0uGUwRCB3tkT5J36BYsZngN8o/lr0O3FbRbJfbBDkZlvGAreQKUdMVzynEeZ9OLa
# sDvzRH82iwdtQYQIZTWrNQGN4bJCVOb2DKqEoPnofHHLROGe2D/5YxguiCg9jdxp
# VcHUILir7vQ1X0KLzFAks8Mn7DtEqb8=
# SIG # End signature block
