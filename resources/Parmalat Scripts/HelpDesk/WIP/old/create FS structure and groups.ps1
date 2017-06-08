
Function DeleteFS-OUs {
	$list = Get-ADOrganizationalUnit -SearchBase 'OU=File Server Permissions,OU=Test New Structure,OU=Parmalat Users,DC=parma,DC=internal' -Filter * -SearchScope OneLevel
	foreach ($Entry in $List) {
		Set-ADOrganizationalUnit -Identity $Entry.DistinguishedName -ProtectedFromAccidentalDeletion $false
		Remove-ADOrganizationalUnit -Identity $Entry.DistinguishedName -Recursive
		}
	}

Function Create-FS_OUs {
	$OU = 'OU=File Server Permissions,OU=Test New Structure,OU=Parmalat Users,DC=parma,DC=internal'
	for ($i = 1; $i -le 5; $i++ ) { New-ADOrganizationalUnit -Path $OU -Name $('FS' + $i) -DisplayName $('FS' + $i) -Server $DC }
	}
		
$DC = 'DC2AD2'
$Conn = Connect-QADService -Service $($DC + '.parma.internal')

For ($i = 1; $i -le 5; $i++ ) {

$FailedOUs = @()
$ShareName = '\\fs' + $i + '\Data' + $i + '$'
$DirList = gci $ShareName
$FSOU = 'OU=FS' + $i + ',OU=File Server Permissions,OU=Test New Structure,OU=Parmalat Users,DC=parma,DC=internal'
foreach ($name in $DirList) {
	If ($(Get-ADOrganizationalUnit -Identity $('OU=' + $name.Name + ',' + $FSOU) -Server $DC) -ne $null) {$failedOUs += $name.Name}
		else {New-ADOrganizationalUnit -DisplayName $name.Name -Name $name.Name -ProtectedFromAccidentalDeletion $true -Server $DC -Path $FSOU}
	$list = gci $($ShareName + '\' + $Name.name + '\*') | where -FilterScript {$_.Mode -like 'd*'} | select -Property name
	$OU = 'OU=' + $name.name + ',' + $FSOU
	Foreach ($Dir in $List){
		If ($(Get-QADGroup -Identity $name) -ne $null) {New-QADGroup -ParentContainer $OU -GroupScope DomainLocal -GroupType Security -Name $Dir.name -Connection $conn -DisplayName $Dir.name -SamAccountName $Dir.name}
			Else {New-QADGroup -ParentContainer $OU -GroupScope DomainLocal -GroupType Security -Name $dir.name -Connection $conn -DisplayName $Dir.name -SamAccountName $Dir.name}
		}
	}
}
if ($FailedOUs -ne $null ) {Out-File -InputObject $Failed -FilePath 'M:\temp\failedous.out'}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5s/RHA5Mq1TCqHOiniSB+g/y
# e9egggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FFD9CUgbMym+tKQsi1TQQnvBBKl7MA0GCSqGSIb3DQEBAQUABIGAevHyo5Hz2KW+
# vgKZHso8plIcLs7iMETV2CEjk9zUdPfz+PVp39haxorL0RkBijCYdE+ktJXaX6xz
# USq4YyfgE9yUfCaU8EmHVoBaxob3tlgG38lSnwktvzowMkhUkzFRtmqDdq2bJLG4
# tgJKb8LRPxiHmv8yCIq84zqEXwVzYXg=
# SIG # End signature block
