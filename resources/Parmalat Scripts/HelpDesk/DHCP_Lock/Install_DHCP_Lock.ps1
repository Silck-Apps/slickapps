$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
$SysDir = ('..\common')
. ($SysDir + '\PowerShell.ps1')
. ($SysDir + '\vbFunctions.ps1')
$programs = (Get-SpecialFolders).Programs
$StartItems = $programs + '\DHCP_Lock'

$details = New-Object -TypeName PSObject -Property @{Single='-Action "Allow"','-Action "Remove"','-Action "Deny"'
	Multiple = '-Action "Allow" -Multiple','-Action "Remove" -Multiple','-Action "Deny" -Multiple'
	Name = (New-Object -TypeName PSObject -Property @{ `
		Allow = 'Allow'
		Remove = 'Remove'
		Deny = 'Deny'})
	SinglePath = $startitems + '\Single Mac'
	MultiplePath = $StartItems + '\Multiple Macs'
	}
If ((test-path $StartItems) -eq $false) {New-Item -ItemType 'Directory' -Path $startitems}
If ((test-path $details.singlepath) -eq $false) {New-Item -ItemType 'Directory' -Path $details.singlepath}
If ((test-path $Details.MultiplePath) -eq $false) {New-Item -ItemType 'Directory' -Path $details.multiplepath}

ForEach ($Arg in $details.Single) {Switch ($Arg) {
		'-Action "Allow"' {$name = 'Allow'}
		'-Action "Remove"' {$name = 'Remove'}
		'-Action "Deny"' {$name = 'Deny'}
		}
#	AddShortCut -Arg $arg -Desc $null -folder $details.singlepath -Name $name
	CreateShortcut -Arguments ('-WindowStyle Hidden -File "' + $ScriptDir + '" ' + $Arg) `
		-Description $null -FullName ($details.singlepath + '\' + $name + '.lnk') `
		-WorkingDirectory $HOME -IconLocation 'Powershell.exe' -WindowStyle 7 -TargetPath 'Powershell.exe'}
ForEach ($Arg in $details.multiple) {Switch ($Arg) {
		'-Action "Allow" -multiple' {$name = 'Allow'}
		'-Action "Remove" -multiple' {$name = 'Remove'}
		'-Action "Deny" -multiple' {$name = 'Deny'}
	}
#AddShortCut -Arg $arg -Desc $null -folder $details.multiplepath -Name $name
CreateShortcut -Arguments ('-WindowStyle Hidden -File "' + $ScriptDir + '" ' + $Arg) `
		-Description $null -FullName ($details.multiplepath + '\' + $name + '.lnk') `
		-WorkingDirectory $HOME -IconLocation 'Powershell.exe' -WindowStyle 7 -TargetPath 'Powershell.exe'}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5oBL9y7dOtrluT6rauNUXWVV
# YW+gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FOlNX6MAGmmxO3RwJNbAMgDFSp7LMA0GCSqGSIb3DQEBAQUABIGAl5Ls0j+9zf4Y
# +oCo8hP7ZbPooH76SsBoAWrEoAhZuD9hHaTjisjf2Vq6TPg01HHsWz9jiQoD7BLm
# yO2JKFtPKvb+NIf/PMsFH9hJ7NJuqQsoXXOdWpQqnQ0ypl1RER7/NsBOo9ta9Hlx
# cr5QqM5RttXQqPklGpPY7wKgfGenJAs=
# SIG # End signature block
