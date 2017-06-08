# 
# This script updates existing AD accounts with HR data from SAP using the employee number as the
# unique ID between AD and SAP. HR records from SAP that aren't used to update AD accounts are
# considered staff without AD accounts. A set of AD accounts will be created, updated and removed
# automatically so these staff members are also searchable through the phone directory.
# 


Write-Output ''
Write-Output 'Import CSV files'
Write-Output '==============================================================================='

$arySAPPhoneRecords = import-csv "c:\scripts\sap-hr-to-ad-update\data\sapphonerecords.csv"
$arySitePrefix = import-csv "c:\scripts\sap-hr-to-ad-update\data\siteprefix.csv"
$aryEmployeeNo_withADAccount = New-Object System.Collections.ArrayList
$aryEmployeeNo_withoutADAccount = New-Object System.Collections.ArrayList
$aryEmployeeNo_withoutADAccount_existsInAD = New-Object System.Collections.ArrayList
$aryEmployeeNo_withoutADAccount_doesNotExistInAD = New-Object System.Collections.ArrayList
$aryCcmcontactADAccounts = New-Object System.Collections.ArrayList


Write-Output ''
Write-Output 'Update AD NT User Accounts with telephone records'
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

        if ($ADUser.employeeNumber -ne "")
            {

#                $ADUser.samAccountName
#                $ADUser.employeeNumber
#                $ADUser.telephoneNumber
#                $ADUser.distinguishedName

                $SAPPhoneRecord_EmployeeNo = ''
                $SAPPhoneRecord_KnownAs = ''
                $SAPPhoneRecord_FirstName = ''
                $SAPPhoneRecord_Surname = ''
                $SAPPhoneRecord_CostCentre = ''
                $SAPPhoneRecord_Telephone = ''
                $SAPPhoneRecord_Telephone_Site = ''
                $SAPPhoneRecord_Telephone_withLeadingZero = ''
                $SAPPhoneRecord_Extension = ''
                $SAPPhoneRecord_Extension_withSitePrefix = ''
                $SAPPhoneRecordHasBeenFound = $False
                $useExt = $False

                foreach ($SAPPhoneRecord in $arySAPPhoneRecords)
                    {
                        if ($($SAPPhoneRecord.EmployeeNo) -eq "$($ADUser.employeeNumber)")
                            {
                                $SAPPhoneRecord_EmployeeNo = $SAPPhoneRecord.EmployeeNo
                                $SAPPhoneRecord_KnownAs = $SAPPhoneRecord.KnownAs
                                $SAPPhoneRecord_FirstName = $SAPPhoneRecord.FirstName
                                $SAPPhoneRecord_Surname = $SAPPhoneRecord.Surname
                                $SAPPhoneRecord_Telephone = $SAPPhoneRecord.Telephone -replace '[^0-9]'
                                $SAPPhoneRecord_CostCentre = $SAPPhoneRecord.CostCentre
                                $SAPPhoneRecordHasBeenFound = $True

                                $aryEmployeeNo_withADAccount.add($SAPPhoneRecord_EmployeeNo) > $null
                            }
                    }

                if (($SAPPhoneRecordHasBeenFound -eq $True) -and ($SAPPhoneRecord_Telephone.length -eq 10))
                    {

#                        Write-Output ">>> Processing..."
                        Write-Output $($ADUser.distinguishedName)

                        #
                        # get 3 digit extension site FNN prefix
                        #

                        $SAPPhoneRecord_Extension = $SAPPhoneRecord_Telephone.substring(7,3)
                        $SAPPhoneRecord_Telephone_Site = $SAPPhoneRecord_Telephone.substring(0,7)
                        $SAPPhoneRecord_Telephone_withLeadingZero = '0' + $SAPPhoneRecord_Telephone

                        foreach ($sitePrefixRecord in $arySitePrefix)
                                {
                                    if ($($sitePrefixRecord.site) -eq "$($SAPPhoneRecord_Telephone_Site)")
                                        {
                                            $useExt = $True
                                            $SAPPhoneRecord_Extension_withSitePrefix = $sitePrefixRecord.prefix + $SAPPhoneRecord_Extension
                                        }
                                }

                        #
                        # write FNN to AD telephoneNumber field
                        #

                        if ($($ADUser.telephoneNumber) -ne "$($SAPPhoneRecord_Telephone)")
                            {
                                Write-Output ">>> Updating main telephone number"
                                Write-Output $SAPPhoneRecord_Telephone

                                $objUserUpdate1 = [ADSI]"LDAP://vmccmdc01:389/$($ADUser.distinguishedName)"
                                $objUserUpdate1.put("telephoneNumber", $($SAPPhoneRecord_Telephone))
                                $objUserUpdate1.setInfo()
                            }

                        #
                        # write 5 digit number or FNN with leading zero to AD ipPhone field
                        #

                        if (($useExt -eq $True) -and ($($ADUser.ipPhone) -ne "$($SAPPhoneRecord_Extension_withSitePrefix)"))
                            {
                                Write-Output ">>> Updating ipPhone field with 5 digit number"
                                Write-Output $SAPPhoneRecord_Extension_withSitePrefix

                                $objUserUpdate2 = [ADSI]"LDAP://vmccmdc01:389/$($ADUser.distinguishedName)"
                                $objUserUpdate2.put("ipPhone", $($SAPPhoneRecord_Extension_withSitePrefix))
                                $objUserUpdate2.setInfo()
                            }
                        elseif (($useExt -eq $False) -and ($($ADUser.ipPhone) -ne "$($SAPPhoneRecord_Telephone_withLeadingZero)"))
                            {
                                Write-Output ">>> Updating ipPhone field with all digits"
                                Write-Output $SAPPhoneRecord_Telephone_withLeadingZero

                                $objUserUpdate2 = [ADSI]"LDAP://vmccmdc01:389/$($ADUser.distinguishedName)"
                                $objUserUpdate2.put("ipPhone", $($SAPPhoneRecord_Telephone_withLeadingZero))
                                $objUserUpdate2.setInfo()
                            }

                        #
                        # write CostCentre to AD company field
                        #

                        if ($($ADUser.company) -ne "$($SAPPhoneRecord_CostCentre)")
                            {
                                Write-Output ">>> Updating cost centre"
                                Write-Output $SAPPhoneRecord_CostCentre

                                $objUserUpdate3 = [ADSI]"LDAP://vmccmdc01:389/$($ADUser.distinguishedName)"
                                $objUserUpdate3.put("company", $($SAPPhoneRecord_CostCentre))
                                $objUserUpdate3.setInfo()
                            }

                        Write-Output "----------"

                    }
	    }
    }


Write-Output ''
Write-Output 'Building list of employee numbers without AD accounts'
Write-Output '==============================================================================='

foreach ($SAPPhoneRecord in $arySAPPhoneRecords) 
    {
        if ($aryEmployeeNo_withADAccount.Contains($SAPPhoneRecord.EmployeeNo) -eq $False)
            {
                $aryEmployeeNo_withoutADAccount.add($SAPPhoneRecord.EmployeeNo) > $null
            }
    }


Write-Output ''
Write-Output 'Deleting ccmcontact_* AD accounts where the SAP HR record no longer exists'
Write-Output '==============================================================================='

$objSearcher.SearchRoot = "LDAP://vmccmdc01:389/OU=SAPHRContacts,OU=CCMContacts,DC=ccm,DC=internal"
$objSearcher.SearchScope = "Subtree"
$objSearcher.PageSize = 5000
$objSearcher.Filter = "(objectCategory=User)"
$ADContactRecords = $objSearcher.FindAll()

$objADSI = [ADSI]"LDAP://vmccmdc01:389/OU=SAPHRContacts,OU=CCMContacts,DC=ccm,DC=internal"

foreach ($ADContactRecord in $ADContactRecords)
    {
        $ADContact = $ADContactRecord.GetDirectoryEntry()

        if ($aryEmployeeNo_withoutADAccount.Contains($($ADContact.employeeNumber)) -eq $False)
            {
                Write-Output $ADContact.distinguishedName
                Write-Output $ADContact.displayName
                Write-Output "----------"
                $objADSI.delete("User","cn="+$($ADContact.sAMAccountName))
            }
    }

Write-Output ''
Write-Output 'Updating ccmcontact_* AD accounts where the SAP HR record exists'
Write-Output '==============================================================================='

$ADContactRecords = $objSearcher.FindAll()

foreach ($ADContactRecord in $ADContactRecords)
    {
        $ADContact = $ADContactRecord.GetDirectoryEntry()
        $aryCcmcontactADAccounts.add($($ADContact.sAMAccountName)) > $null

        if ($ADContact.employeeNumber -ne "")
            {

#                $ADContact.samAccountName
#                $ADContact.employeeNumber
#                $ADContact.telephoneNumber
#                $ADContact.distinguishedName

                $SAPPhoneRecord_EmployeeNo = ''
                $SAPPhoneRecord_KnownAs = ''
                $SAPPhoneRecord_FirstName = ''
                $SAPPhoneRecord_Surname = ''
                $SAPPhoneRecord_CostCentre = ''
                $SAPPhoneRecord_Telephone = ''
                $SAPPhoneRecord_Telephone_Site = ''
                $SAPPhoneRecord_Telephone_withLeadingZero = ''
                $SAPPhoneRecord_Extension = ''
                $SAPPhoneRecord_Extension_withSitePrefix = ''
                $SAPPhoneRecordHasBeenFound = $False
                $useExt = $False

                foreach ($SAPPhoneRecord in $arySAPPhoneRecords)
                    {
                        if ($($SAPPhoneRecord.EmployeeNo) -eq "$($ADContact.employeeNumber)")
                            {
                                $SAPPhoneRecord_EmployeeNo = $SAPPhoneRecord.EmployeeNo
                                $SAPPhoneRecord_KnownAs = $SAPPhoneRecord.KnownAs
                                $SAPPhoneRecord_FirstName = $SAPPhoneRecord.FirstName
                                $SAPPhoneRecord_Surname = $SAPPhoneRecord.Surname
                                $SAPPhoneRecord_Telephone = $SAPPhoneRecord.Telephone -replace '[^0-9]'
                                $SAPPhoneRecord_CostCentre = $SAPPhoneRecord.CostCentre
                                $SAPPhoneRecordHasBeenFound = $True

                                $aryEmployeeNo_withoutADAccount_existsInAD.add($SAPPhoneRecord_EmployeeNo) > $null
                            }
                    }

                if (($SAPPhoneRecordHasBeenFound -eq $True) -and ($SAPPhoneRecord_Telephone.length -eq 10))
                    {

#                        Write-Output ">>> Processing..."
                        Write-Output $ADContact.distinguishedName

                        #
                        # check whether to use knownas or firstname and write to AD
                        #

                        if ($($SAPPhoneRecord_KnownAs) -ne "")
                            {
                                $SAPPhoneRecord_FirstName = $SAPPhoneRecord_KnownAs
                            }

                        if (($($ADContact.givenName) -ne "$($SAPPhoneRecord_FirstName)") -or ($($ADContact.sn) -ne "$($SAPPhoneRecord_Surname)") -or ($($ADContact.displayName) -ne "$($SAPPhoneRecord_FirstName)"+" "+"$($SAPPhoneRecord_Surname)"))
                            {
                                Write-Output ">>> Updating name"
                                Write-Output $SAPPhoneRecord_FirstName
                                Write-Output $SAPPhoneRecord_Surname

                                $objUserUpdate0 = [ADSI]"LDAP://vmccmdc01:389/$($ADContact.distinguishedName)"
                                $objUserUpdate0.put("givenName", $($SAPPhoneRecord_FirstName))
                                $objUserUpdate0.put("sn", $($SAPPhoneRecord_Surname))
                                $objUserUpdate0.put("displayName" , $($SAPPhoneRecord_FirstName)+" "+$($SAPPhoneRecord_Surname))
                                $objUserUpdate0.setInfo()
                            }

                        #
                        # get 3 digit extension site FNN prefix
                        #

                        $SAPPhoneRecord_Extension = $SAPPhoneRecord_Telephone.substring(7,3)
                        $SAPPhoneRecord_Telephone_Site = $SAPPhoneRecord_Telephone.substring(0,7)
                        $SAPPhoneRecord_Telephone_withLeadingZero = '0' + $SAPPhoneRecord_Telephone

                        foreach ($sitePrefixRecord in $arySitePrefix)
                                {
                                    if ($($sitePrefixRecord.site) -eq "$($SAPPhoneRecord_Telephone_Site)")
                                        {
                                            $useExt = $True
                                            $SAPPhoneRecord_Extension_withSitePrefix = $sitePrefixRecord.prefix + $SAPPhoneRecord_Extension
                                        }
                                }

                        #
                        # write FNN to AD telephoneNumber field
                        #

                        if ($($ADContact.telephoneNumber) -ne "$($SAPPhoneRecord_Telephone)")
                            {
                                Write-Output ">>> Updating main telephone number"
                                Write-Output $SAPPhoneRecord_Telephone

                                $objUserUpdate1 = [ADSI]"LDAP://vmccmdc01:389/$($ADContact.distinguishedName)"
                                $objUserUpdate1.put("telephoneNumber", $($SAPPhoneRecord_Telephone))
                                $objUserUpdate1.setInfo()
                            }

                        #
                        # write 5 digit number or FNN with leading zero to AD ipPhone field
                        #

                        if (($useExt -eq $True) -and ($($ADContact.ipPhone) -ne "$($SAPPhoneRecord_Extension_withSitePrefix)"))
                            {
                                Write-Output ">>> Updating ipPhone field with 5 digit number"
                                Write-Output $SAPPhoneRecord_Extension_withSitePrefix

                                $objUserUpdate2 = [ADSI]"LDAP://vmccmdc01:389/$($ADContact.distinguishedName)"
                                $objUserUpdate2.put("ipPhone", $($SAPPhoneRecord_Extension_withSitePrefix))
                                $objUserUpdate2.setInfo()
                            }
                        elseif (($useExt -eq $False) -and ($($ADContact.ipPhone) -ne "$($SAPPhoneRecord_Telephone_withLeadingZero)"))
                            {
                                Write-Output ">>> Updating ipPhone field with all digits"
                                Write-Output $SAPPhoneRecord_Telephone_withLeadingZero

                                $objUserUpdate2 = [ADSI]"LDAP://vmccmdc01:389/$($ADContact.distinguishedName)"
                                $objUserUpdate2.put("ipPhone", $($SAPPhoneRecord_Telephone_withLeadingZero))
                                $objUserUpdate2.setInfo()
                            }

                        #
                        # write CostCentre to AD company field
                        #

                        if ($($ADContact.company) -ne "$($SAPPhoneRecord_CostCentre)")
                            {
                                Write-Output ">>> Updating cost centre"
                                Write-Output $SAPPhoneRecord_CostCentre

                                $objUserUpdate3 = [ADSI]"LDAP://vmccmdc01:389/$($ADContact.distinguishedName)"
                                $objUserUpdate3.put("company", $($SAPPhoneRecord_CostCentre))
                                $objUserUpdate3.setInfo()
                            }

                        Write-Output "----------"

                    }
	    }
    }


Write-Output ''
Write-Output 'Adding new ccmcontact_* AD accounts where the SAP HR record exists'
Write-Output '==============================================================================='

$ADS_UF_NORMAL_ACCOUNT = 512

$rand = New-Object System.Random
$randCharsAlpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
$randCharsOther = "!@#$%^&*1234567890"
$randPassLength = 8

$groupDomainUsers = [ADSI]"LDAP://vmccmdc01:389/CN=Domain Users,CN=Users,DC=ccm,DC=internal"
$groupCCMContacts = [ADSI]"LDAP://vmccmdc01:389/CN=CCMContactsGroup,CN=Users,DC=ccm,DC=internal"
$groupCCMContactsID = 1115

foreach ($EmployeeNo_withoutADAccount in $aryEmployeeNo_withoutADAccount) 
    {
        if ($aryEmployeeNo_withoutADAccount_existsInAD.Contains($EmployeeNo_withoutADAccount) -eq $False)
            {
                $aryEmployeeNo_withoutADAccount_doesNotExistInAD.add($EmployeeNo_withoutADAccount) > $null
            }
    }

foreach ($EmployeeNo_withoutADAccount_doesNotExistInAD in $aryEmployeeNo_withoutADAccount_doesNotExistInAD) 
    {

        $SAPPhoneRecord_EmployeeNo = ''
        $SAPPhoneRecord_KnownAs = ''
        $SAPPhoneRecord_FirstName = ''
        $SAPPhoneRecord_Surname = ''
        $SAPPhoneRecord_CostCentre = ''
        $SAPPhoneRecord_Telephone = ''
        $SAPPhoneRecord_Telephone_Site = ''
        $SAPPhoneRecord_Telephone_withLeadingZero = ''
        $SAPPhoneRecord_Extension = ''
        $SAPPhoneRecord_Extension_withSitePrefix = ''
        $SAPPhoneRecordHasBeenFound = $False
        $useExt = $False

        foreach ($SAPPhoneRecord in $arySAPPhoneRecords)
            {
                if ($($SAPPhoneRecord.EmployeeNo) -eq "$($EmployeeNo_withoutADAccount_doesNotExistInAD)")
                    {
                        $SAPPhoneRecord_EmployeeNo = $SAPPhoneRecord.EmployeeNo
                        $SAPPhoneRecord_KnownAs = $SAPPhoneRecord.KnownAs
                        $SAPPhoneRecord_FirstName = $SAPPhoneRecord.FirstName
                        $SAPPhoneRecord_Surname = $SAPPhoneRecord.Surname
                        $SAPPhoneRecord_Telephone = $SAPPhoneRecord.Telephone -replace '[^0-9]'
                        $SAPPhoneRecord_CostCentre = $SAPPhoneRecord.CostCentre
                        $SAPPhoneRecordHasBeenFound = $True
                    }
            }

        if (($SAPPhoneRecordHasBeenFound -eq $True) -and ($SAPPhoneRecord_Telephone.length -eq 10))
            {
                #
                # generate random and unique ccmcontact_****
                #

                $nextRand = $rand.Next(10000000,99999999)
                while ($aryCcmcontactADAccounts.Contains("ccmcontact_"+$($nextRand)) -eq $True)
                    {
                        $nextRand = $rand.Next(10000000,99999999)
                    }

                #
                # create the account
                #

                $usrname = "cn=ccmcontact_"+$($nextRand)
                $objNewUser = $objADSI.create("User",$usrName)
                $objNewuser.setInfo()

                $objNewUser.put("sAMAccountName","ccmcontact_"+$($nextRand))
                $objNewUser.put("userPrincipalName","ccmcontact_"+$($nextRand)+"@ccm.internal")
                $objNewUser.setInfo()

                Write-Output ">>> Created ccmcontact account for"
                Write-Output $objNewuser.distinguishedName

                Write-Output ">>> Adding employee number"
                Write-Output $SAPPhoneRecord_EmployeeNo

                $objNewUser.put("employeeNumber", $($SAPPhoneRecord_EmployeeNo))
                $objNewUser.setInfo()

                #
                # check whether to use knownas or firstname
                #

                if ($($SAPPhoneRecord_KnownAs) -ne "")
                    {
                        $SAPPhoneRecord_FirstName = $SAPPhoneRecord_KnownAs
                    }

                #
                # write firstname, surname, displayname to AD
                #

                Write-Output ">>> Adding firstname, surname, displayname"
                Write-Output $SAPPhoneRecord_FirstName
                Write-Output $SAPPhoneRecord_Surname

                $objNewUser.put("givenName", $($SAPPhoneRecord_FirstName))
                $objNewUser.put("sn", $($SAPPhoneRecord_Surname))
                $objNewUser.put("displayName", $($SAPPhoneRecord_FirstName)+" "+$($SAPPhoneRecord_Surname))
                $objNewUser.setInfo()

                #
                # get 3 digit extension and site FNN prefix
                #

                $SAPPhoneRecord_Extension = $SAPPhoneRecord_Telephone.substring(7,3)
                $SAPPhoneRecord_Telephone_Site = $SAPPhoneRecord_Telephone.substring(0,7)
                $SAPPhoneRecord_Telephone_withLeadingZero = '0' + $SAPPhoneRecord_Telephone

                foreach ($sitePrefixRecord in $arySitePrefix)
                    {
                        if ($($sitePrefixRecord.site) -eq "$($SAPPhoneRecord_Telephone_Site)")
                            {
                                $useExt = $True
                                $SAPPhoneRecord_Extension_withSitePrefix = $sitePrefixRecord.prefix + $SAPPhoneRecord_Extension
                            }
                    }

                #
                # write FNN to AD telephoneNumber field
                #

                Write-Output ">>> Adding main telephone number"
                Write-Output $SAPPhoneRecord_Telephone

                $objNewUser.put("telephoneNumber", $($SAPPhoneRecord_Telephone))
                $objNewUser.setInfo()

                #
                # write 5 digit number or FNN with leading zero to AD ipPhone field
                #

                if ($useExt -eq $True)
                    {
                        Write-Output ">>> Adding ipPhone field with 5 digit number"
                        Write-Output $SAPPhoneRecord_Extension_withSitePrefix

                        $objNewUser.put("ipPhone", $($SAPPhoneRecord_Extension_withSitePrefix))
                        $objNewUser.setInfo()
                    }
                elseif ($useExt -eq $False)
                    {
                        Write-Output ">>> Adding ipPhone field with all digits"
                        Write-Output $SAPPhoneRecord_Telephone_withLeadingZero

                        $objNewUser.put("ipPhone", $($SAPPhoneRecord_Telephone_withLeadingZero))
                        $objNewUser.setInfo()
                    }

                #
                # write CostCentre to AD company field
                #

                Write-Output ">>> Updating cost centre"
                Write-Output $SAPPhoneRecord_CostCentre

                $objNewUser.put("company", $($SAPPhoneRecord_CostCentre))
                $objNewUser.setInfo()

                #
                # create random password and set
                #

                $randPassword = ""
                for ($i = $randPassLength; $i -gt 0; $i--)
                    {
                        $randPassword += $randCharsAlpha.Chars($rand.Next(0,$randCharsAlpha.Length-1))
                        $randPassword += $randCharsOther.Chars($rand.Next(0,$randCharsOther.Length-1))
                    }

                $objNewUser.SetPassword($randPassword)
                $objNewUser.setInfo()

                $objNewUser.userAccountControl = $ADS_UF_NORMAL_ACCOUNT
                $objNewUser.setInfo()

                #
                # set correct groups
                #

                $groupCCMContacts.add("LDAP://vmccmdc01:389/" + $($objNewUser.distinguishedName))
                $groupCCMContacts.setInfo()

                $objNewUser.primaryGroupID = $groupCCMContactsID
                $objNewUser.setInfo()

                $groupDomainUsers.remove("LDAP://vmccmdc01:389/" + $($objNewUser.distinguishedName))
                $groupDomainUsers.setInfo()

                Write-Output "----------"
            }
    }



#Write-Output ''
#Write-Output 'aryEmployeeNo_withADAccount'
#$aryEmployeeNo_withADAccount

#Write-Output ''
#Write-Output 'aryEmployeeNo_withoutADAccount'
#$aryEmployeeNo_withoutADAccount

#Write-Output ''
#Write-Output 'aryEmployeeNo_withoutADAccount_existsInAD'
#$aryEmployeeNo_withoutADAccount_existsInAD

#Write-Output ''
#Write-Output 'aryEmployeeNo_withoutADAccount_doesNotExistInAD'
#$aryEmployeeNo_withoutADAccount_doesNotExistInAD

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWjPyIXnBQWfrnmsIon1rPDf6
# aRGgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FHC48H1y2XL6HrZquGiIK47PrE8QMA0GCSqGSIb3DQEBAQUABIGAiAgmXu0nJFb6
# 3EbJhYrv3hKK3FbAP4eKieN+hfZdJXmPEWlAzVa+4F6bg5771fM+pte6eqQOnv2N
# jYv0997KGzLNieukb0knG8cWFqhFD4g+BpiETcPHtcy8UIUWKT7bgZ5z7T7y6GIo
# 4DvilhklmKMdxB7IXz31CQHFievc7Zs=
# SIG # End signature block
