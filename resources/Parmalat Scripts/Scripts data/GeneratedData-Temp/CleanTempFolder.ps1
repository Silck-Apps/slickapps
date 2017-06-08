$LogFile = "\\parma.internal\dfsroot\GBS\HelpDesk\Scripts\Logs\CleanTempFolder.log"
'**************   Start Log   ********************' | Out-File $LogFile -Append -NoClobber
'' | Out-File $LogFile -Append -NoClobber
'Current Date: ' + (Get-Date).tolongdatestring() | Out-File $LogFile -Append -NoClobber
[Int]$Month = Get-Date -UFormat "%m"
[Int]$Year = Get-Date -UFormat '%Y'
[Int]$Day = Get-Date -UFormat '%d'
If ($Month -lt 2){$Month = $Month + 12
	$Year = $Year - 1}
$Month = $Month - 2
'Target Date : ' + (Get-Date -Day $Day -Month $Month -Year $Year).tolongdatestring() | Out-File $LogFile -Append -NoClobber
'' | Out-File $LogFile -Append -NoClobber
$i = 0
ForEach ($item in (Get-ChildItem -Exclude 'CleanTempFolder.ps1')) {
	$delete = $false
	$Created = $($item.creationtime.toshortdatestring()).split('/')
	[Int]$FileMonth = $Created[0]
	[Int]$FileMonth = $Created[1]
	[Int]$FileYear = $Created[2]
	If ($FileYear -lt $Year){$Delete = $true}
	Else {If ($FileMonth -lt $Month) {$Delete = $true}
		Else {If ($FileDay -le $Day) {$delete = $true}}
	}
	If ($delete = $true) {Remove-Item -Path $item.FullName -Recurse -Force
		$item.FullName | Out-File $LogFile -Append -NoClobber}
	$i++
}
If ($i -eq 0){'No Files To Delete' | Out-File $LogFile -Append -NoClobber}
'' | Out-File $LogFile -Append -NoClobber
'**************   End Log   ****************' | Out-File $LogFile -Append -NoClobber

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKmR0AY1ntu6bFP7sb3RiSmED
# s9igggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FBTE7AQqX1zxujAbMWnNA/11FnDGMA0GCSqGSIb3DQEBAQUABIGAhNw5Hq7XBDj7
# eE3DQV+hwpvPThmiBrbAjXb4v1EDw+3ech4aZj01JHcBNUT6WNAamh7NA+DJIbrZ
# oHBUjTuMWAT5bOWkDS7wqe41j4J4vTRw+zSIFvkyisxxGWeVUTRQdKL8La3+vJAT
# afWE05ZtBYIhbin2pXLgeN/NJlmyOz8=
# SIG # End signature block
