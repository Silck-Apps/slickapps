$LogFile = "\\parma.internal\dfsroot\GBS\HelpDesk\Scripts\Logs\CleanTempFolder.log"
'**************   Start Log   ********************' | Out-File $LogFile -Append -NoClobber
'' | Out-File $LogFile -Append -NoClobber
'Current Date: ' + (Get-Date).tolongdatestring() | Out-File $LogFile -Append -NoClobber
'Target Date: ' + (Get-Date).addmonths(-6).tolongdatestring() | Out-File $LogFile -Append -NoClobber
'' | Out-File $LogFile -Append -NoClobber
$delete = $false
ForEach ($item in (Get-ChildItem . -Exclude 'CleanTempFolder.ps1')) {
	If ($item.creationtime -le (Get-Date).addmonths(-6)) {Remove-Item -Path $item.fullname -Recurse -Force
		$item.fullname | Out-File $LogFile -Append -NoClobber
		$delete = $true}
	}
If ($delete -eq $false) {'No Files To Delete' | Out-File $LogFile -Append -NoClobber}
'' | Out-File $LogFile -Append -NoClobber
'**************   End Log   ****************' | Out-File $LogFile -Append -NoClobber



# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTRMVFCprAPB5HYkzloUeWVcg
# ubmgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FG2AqWQe820yiITZwjob3bQdLiDKMA0GCSqGSIb3DQEBAQUABIGASZjfyExx61V7
# ZBRjGizFVYmPQRUehYvj0LHv9jDDRfOXi0EzUPPAWWdJYGYsmaKTPJRk4U/TJCfN
# ZSrS8IdEhEI98BeyIsOV7/gzU416qmyKWSISOd02wkC1TKASHdK0tQ0bBIFpkPMB
# OaDVI7XLvRNzJsXclz60S54bmKR9fDw=
# SIG # End signature block
