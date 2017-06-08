foreach ($name in (Get-QADGroupMember 'Social Club Members' | where -FilterScript {$_.type -eq 'Contact'})) 
	{ Move-QADObject -Identity $name.DN -NewParentContainer 'OU=Social Club,OU=Custom Recipients,OU=Parmalat Users,DC=parma,DC=internal'}
	
foreach ($name in (get-mailcontact | where -FilterScript {$_.primarysmtpaddress -like '*messagenet.com.au'}))
	{ Move-QADObject -Identity $name.DistinguishedName -NewParentContainer 'OU=SMS Contacts,OU=Custom Recipients,OU=Parmalat Users,DC=parma,DC=internal'}
	
foreach ($name in (Get-QADObject -SearchRoot 'parma.internal/Parmalat Users/Custom Recipients' -SearchScope OneLevel | `
		where -FilterScript {$_.type -eq 'Contact'} | where -FilterScript {$_.memberof -like '*PDS*'}))
	{Move-QADObject -Identity $name.DN -NewParentContainer 'OU=Distributors,OU=Custom Recipients,OU=Parmalat Users,DC=parma,DC=internal'}
	
foreach ($name in (Get-QADObject -SearchRoot 'parma.internal/Parmalat Users/Custom Recipients' -SearchScope OneLevel | `
		where -FilterScript {$_.type -eq 'Contact'} | where -FilterScript {$_.name -like '*Fax*'}))
	{Move-QADObject -Identity $name.DN -NewParentContainer 'OU=Fax Contacts,OU=Custom Recipients,OU=Parmalat Users,DC=parma,DC=internal'}

foreach ($name in (Get-QADObject -SearchRoot 'parma.internal/Parmalat Users/Custom Recipients' -SearchScope OneLevel | `
		where -FilterScript {$_.type -eq 'Contact'} | where -FilterScript {$_.primarysmtpaddress -like '*@*.*'}))
	{Move-QADObject -Identity $name.DN -NewParentContainer 'OU=Email,OU=Custom Recipients,OU=Parmalat Users,DC=parma,DC=internal'}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjqWNBrscorDg9H9KudzhVIyg
# uEGgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FF3AKEVGfctrnl/GsDQa4dvyKlMJMA0GCSqGSIb3DQEBAQUABIGAFRSAXzc+5+n3
# TwKz5ih0Xvg/O9s9tE/cshRRNLhYQNBOScur8HTQxPA7YejKl3vbHVocsqFpYBMR
# MLbnSCtESk+EhKVp15nuC4kTQFsnisTec7IVWrJcFzsRkcAxcEza3eEiZsI22+zJ
# xQMiMQfWgIbQcToUTm7v5lMkMPIPF+8=
# SIG # End signature block
