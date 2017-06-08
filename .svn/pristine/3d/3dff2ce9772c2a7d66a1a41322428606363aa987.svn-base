# 
# This script ...
# 


Write-Output ''
Write-Output 'Import CSV files'
Write-Output '==============================================================================='

$aryNTUserEmployeeNumber = import-csv "c:\scripts\sap-hr-to-ad-update\data\NTUserEmployeeNumber.csv"

#$aryEmployeeNo_withADAccount = New-Object System.Collections.ArrayList


Write-Output ''
Write-Output 'Update AD NT User Accounts with employee numbers'
Write-Output '==============================================================================='

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = "LDAP://vmccmdc01:389/OU=Parmalat Users,DC=ccm,DC=internal"
$objSearcher.SearchScope = "Subtree"
$objSearcher.PageSize = 5000
$objSearcher.Filter = "(objectCategory=User)"
$ADUserRecords = $objSearcher.FindAll()

foreach ($ADUserRecord in $ADUserRecords) 
    {
        $ADUser = $ADUserRecord.GetDirectoryEntry()

        $RecordHasBeenFound = $False

        if ($ADUser.sAMAccountName -ne "")
            {

                foreach ($NTUserEmployeeNumber in $aryNTUserEmployeeNumber)
                    {

                        if ($($ADUser.sAMAccountName).ToLower() -eq $($NTUserEmployeeNumber.username).ToLower())
                            {
                                $employeeNumber = $($NTUserEmployeeNumber.employeeNumber)
                                $RecordHasBeenFound = $True
                            }
                    }

                if ($RecordHasBeenFound -eq $True)
                    {
                        Write-Output $($ADUser.distinguishedName)

                        if ($($ADUser.employeeNumber) -ne $($employeeNumber))
                            {
                                Write-Output ">>> Updating employee number"
                                Write-Output $employeeNumber

                                read-host 'Press enter to apply these details'

                                $objUserUpdate1 = [ADSI]"LDAP://vmccmdc01:389/$($ADUser.distinguishedName)"
                                $objUserUpdate1.put("employeeNumber", $($employeeNumber))
                                $objUserUpdate1.setInfo()
                            }

                        Write-Output "----------"
                    }
	    }
    }

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVKsFroL/CbG8HUNSENpl1ZhF
# BzWgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FGxBKa0/ZDONAxr52EzL/stB7StGMA0GCSqGSIb3DQEBAQUABIGAkb6XT2QAtGF3
# iO98TnsMV4/k6U7Uel1rILCtxCGPzbxumthN1z5xOVoJspdPF29GD8YJZult5eGm
# A7KRoLIrUMhTG3V37oWDck3S9A3Rr22Kn78wIq16sAjGJ07XGqQ+iWz1yAPSPNLg
# GMKzwRo6HuH4k9Bo1aunyl9WwVQ4XXg=
# SIG # End signature block
