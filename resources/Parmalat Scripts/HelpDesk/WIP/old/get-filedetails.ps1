$files = get-childitem -Path "O:\" -Name "*.xls" -Recurse
$details = @('"FullName","Owner","CreationTime","LastAccessTime","LastWriteTime","SizeMB"')

foreach ($Item in $files) {
	$Item = Get-Item -Path $("\\fs1\data1$\" + $Item)
	$ACL = Get-Acl -Path $Item.FullName
	$details += $('"' + $item.FullName + '","' + $ACL.owner + '","' + $Item.creationtime + '","' + `
		$Item.LastAccessTime + '","' + $Item.LastWriteTime + '","' + $($Item.length/1MB) + '"')
	}
#ConvertTo-Csv -InputObject $details | out-file -FilePath "M:\temp\filedetails.csv"

#$progrp = Get-ADGroupMember -Identity "Citrix OfficePro Use" | select name
#$prostdgrp = Get-ADGroupMember -Identity "Citrix OfficePro -Now Std" | select name


#$prouser = @()
#$instdnotpro = @()
#$i = 0
#foreach ($name in $progrp) {
#	$match = $false
#	$i++
#	foreach ($othername in $prostdgrp) {
#		If ($othername -ieq $name) {$match = $true; break}
#			Else {$match = $false}
#		}
#	
#	If ($i -ge $progrp.Count) {$instdnotpro += $othername}
#		Else { If ($match -eq $false) {$prouser += $name}}
#	
##	If (($match -eq $false) -and ($i -ge $progrp.count)) {$prouser += $name}
#		Else {$instdnotpro += $othername}
#	$i = 0
#	}




# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUydeegtEgNepO+R6DC/kSWoRX
# Q5SgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FIRy9UqGk+q+CeSNb+O2EclH78kpMA0GCSqGSIb3DQEBAQUABIGAkuWDGiW7g9t9
# UfTBXiJqgHkq1u6jVj/n/KVV9F3sAlBFwVC5iTnhzQhdhucKlKCdwSaDfMhvBJu2
# eVc13wq5wdnqAhbq0mTI+svLGKKjAphExBWaAKVtHbA69uVS156Gb25nuwUGS46Q
# mnQ6Mxmn1V2uz2RAJI/gvM2HbPkRZmE=
# SIG # End signature block
