$DC = 'DC2AD2'
$Conn = Connect-QADService -Service $($DC + '.parma.internal')

For ($i = 1; $i -le 5; $i++ ) {

$FSOU = 'OU=FS' + $i + ',OU=File Server Permissions,OU=Test New Structure,OU=Parmalat Users,DC=parma,DC=internal'
$OUs = Get-ADOrganizationalUnit -SearchBase $FSOU -SearchScope OneLevel -Filter *

Foreach ($Entry in $OUs) {
	$folders = gci $('\\FS' + $i + '\Data' + $i + '$\' + $entry.Name) | where -FilterScript {$_.Mode -like 'd*'}
	$Groups = Get-QADGroup -SearchRoot $Entry.DistinguishedName
	if ($Groups.count -ne $folders.count) {$entry.Name | Out-File M:\temp\errors.out -Append -NoClobber}
	}

}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCmhP0tXL/D52Xk6t3GfIlVhR
# 7iegggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FK0heNryeVfTHMQ0XyDI/AJ8S6D1MA0GCSqGSIb3DQEBAQUABIGAhso1R9oDf7Ut
# DP2hW/EoIWwUyMS1FxiKQKaoWk57eH2hnX/9VhiZ5ObtlMQ9w9OARivLpXHTSMwR
# JO/HPdUc/Bqay1KNOECIMvEj1J0NIe75lHEe5eas4Rvbf5BA7w6iHBPbCOcKs5hT
# YcaDxqp6mMBObNibykZTo9SgeZvnfl0=
# SIG # End signature block
