$Store = $ScriptsDir + '\GeneratedData-Temp'
Import-Module activedirectory
$folder = '\\fs3\bennettw$\temp\exports'
$files = Get-ChildItem ($folder + '\*.txt')

foreach ($File in $files) {
	$names = Get-Content $file.FullName
	$data = @()
	$data += '"DisplayName","SAMAccountName","mail"'
	ForEach ($Name in $names) {
		$user = Get-ADUser -Identity $Name
		$DN = "LDAP://" + $user.DistinguishedName
		$user = [ADSI]"$DN"
		$data += '"' + $user.displayName + '","' + $user.sAMAccountName + '","' + $user.mail + '"'
		}
	Out-File -InputObject $data -FilePath ($folder + '\AD_Data_' + $File.BaseName + '.csv')
	}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnn/jNM0ybdARveGs3SYjmWky
# k1OgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FBqT7Ze+Ih196M/a9eh5zbCADTCFMA0GCSqGSIb3DQEBAQUABIGAeYSTui1dzcjI
# 6xyvE3ZikpKOuAK0wdnVAMN2P1UZn1fnSDOj2dcSNnmk0ID+O5WApae6PkiRnpG7
# 46y12EUiOotlq7/LHjmNYJBAZaTcqAg8bP0ifQ7kK8iu/z6QC9DzMAWiJ8G84RFB
# J4C189QxqBBNFv94EFF9aLllBwZXAIw=
# SIG # End signature block
