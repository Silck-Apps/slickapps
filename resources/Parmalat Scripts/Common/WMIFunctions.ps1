####### Returns English for Win_32Share WMI Return Value    #####################
function func_Win32_ShareReturnValue {Param($Result)
	Switch($Result){
		0 {$strResult = "Success"}
		2 {$strResult = "Access Denied"}
		8 {$strResult = "Unknown Failure"}
		9 {$strResult = "Invalid Name"}
		10 {$strResult = "Invalid Level"}
		21 {$strResult = "Invalid Parameter"}
		22 {$strResult = "Duplicate Share"}
		23 {$strResult = "Redirected Path"}
		24 {$strResult = "Unkown Device or Directory"}
		25 {$strResult = "Net Name not found"}
		default {$strResult = "WMI Win32_Share function Failed"}
		}
	Return $strResult
}

Function ShareFolder { Param ($ShareDir, $ShareName, $FS)
	$SecDesc = ([WMIClass]"\\$FS\root\cimv2:WIn32_SecurityDescriptor").CreateInstance()
	$Trustee = ([WMIClass]"\\$FS\root\cimv2:WIn32_Trustee").CreateInstance()
	$ACE = ([WMIClass]"\\$FS\root\cimv2:WIn32_ACE").CreateInstance()
	$Trustee.Domain = $null
	$Trustee.Name = "EVERYONE"
	$Trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	$ACE.AccessMask = 2032127
	$ACE.AceFlags = 3
	$ACE.AceType = 0
	$ACE.Trustee = $Trustee
	$SecDesc.DACL = $ACE
	$Result = ([WmiClass] "\\$FS\Root\cimv2:Win32_Share" ).Create($ShareDir,$shareName,0, $null, $null, $null, $secDesc)
	$Result = func_Win32_ShareReturnValue $Result.ReturnValue
	Return $Result
	}

Function getWMI-UserSessions {Param ($server = $env:COMPUTERNAME, $username = $null, [switch]$ReturnFriendlyList)
	$list = $null
	$Err = $ErrorActionPreference
	$ErrorActionPreference = "SilentlyContinue"
	$sessions = Get-WmiObject -Namespace "ROOT\Citrix" -ComputerName $server -Class "MetaFrame_Session" | 
			where -FilterScript {(($_.SessionState -eq 0) -or ($_.SessionState -eq 4)) -and ($_.SessionName -notlike "Services")}
	$ErrorActionPreference = $Err
	Switch ($sessions) {
		($null) {$List = "ConnectionFailed"}
		default {
			if ($ReturnFriendlyList.IsPresent -eq $true) {$list += @(make-friendlylist -session $_)}	
			else { $list += @($_) }
		}
	}
	if (($username -notlike $null) -and ($list -notlike "ConnectionFailed")) {
		$alllist = $list
		$FilterList = $null
		foreach ($Item in $alllist) {
			$SessionUser = $($($item.SessionUser.Split('=')[1]).trim(",AccAuthority")).trim('"')
			if ($SessionUser -like $username) {$FilterList += @($Item)}
		}
		If ($Filterlist -like $null) {$list = "NoMatches"}
		else {$list = $FilterList}
	}
Return $list
}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMYkd5UjHPulGRopwrcCG+Ix5
# m9CgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FMG/3Jeongzf44sNnQYE2OffY7o+MA0GCSqGSIb3DQEBAQUABIGATcORxeBH8Ptw
# Pp3P/VxGEGITLIzu94pe2Ht/E+oapJqlyS6z3Xu+pTbEZaaXcFDZbFEIAKflWv13
# 9VOgxICckS2BqYmRwwBwDY/kHx5JPBbNtVuRQ6K4fSIl5NHSOrv1WwjrmHFkWeIP
# cH8IeNHz3iXWMb6ElxbetxN5teG5oa8=
# SIG # End signature block
