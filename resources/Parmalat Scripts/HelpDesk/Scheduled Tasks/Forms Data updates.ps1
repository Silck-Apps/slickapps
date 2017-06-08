$Error.Clear()
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('\HelpDesk\Scheduled Tasks','') + 'common')
$temp = $env:TEMP + "\HelpDeskForms"
$WWData = "\\vmgbsadmin\C$\WHoWho\WW.csv"
$sitelist = "\\FS2\data2$\GBS\HelpDesk\Scripts\PowerShellData.xls"
. ($SysDir + "\ParmalatData.ps1")
. ($SysDir + "\vbFunctions.ps1")
$SPSiteName = "http://spintranet01/home"
$SPLibrary = "Help Desk Forms Data"
#$HRData = Import-Csv $HRData
$WWData = Import-Csv $WWData
$Departments = @()
$CostCenters = @()
$Locations = @()

foreach ($rec in $WWData) { $rec.FN = $($rec.FN.Substring(0, 1).ToUpper() + $rec.FN.Substring(1, $($rec.FN.Length - 1)).ToLower())
							$rec.LN = $($rec.LN.Substring(0, 1).ToUpper() + $rec.LN.Substring(1, $($rec.LN.Length - 1)).ToLower())
	if ($rec -notlike $null) {
	$match = $false
	foreach ($entry in $Departments) {if ($entry -like $rec.department) {$match = $true}}
	if ($match -eq $false) {if ($rec.department -notlike $null) {$departments += $rec.department}}
	$rec.CC = $rec.CC.Trim("0"); $match = $false
	foreach ($entry in $CostCenters) {if ($entry -like $rec.CC) {$match = $true}}
	if ($match -eq $false) {$CostCenters += $rec.cc}
	}
}

# Change to correct case: FN, LN

$addresses = Read-SpreadSheet -filePath $sitelist -SheetName 'SiteAddresses'
foreach ($entry in $addresses) {$locations += $entry.sitename}
$Locations = $Locations | Sort-Object
$CostCenters = $CostCenters | Sort-Object
$departments = $departments | Sort-Object
$WWData = $WWData | Sort-Object
if ($(Test-Path $temp) -eq $true) {Remove-Item $temp -Recurse -Force}
New-Item -Path $temp -ItemType Directory
Export-Clixml -Path $($temp + "\departments.xml") -InputObject $departments
Export-Clixml -Path $($temp + "\locations.xml") -InputObject $Locations
Export-Clixml -Path $($temp + "\costcenters.xml") -InputObject $CostCenters
Export-Clixml -Path $($temp + "\WWData.xml") -InputObject $WWData
$list = processlist -string '"departments","locations","costcenters","WWData"'
foreach ($Item in $list) {C:\SVN\Scripts\Common\FciSharePointUpload.ps1 -file $($temp + '\' + $Item + '.xml') `
		-url $SPSiteName -libpath $SPLibrary -name $($item + '.xml') `
		-sourceaction delete -targetaction overwrite -propertyaction ignore
	}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBtzKfbIR6TEqG5p5EAt3rZbv
# aXmgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FOPT5Z/m7+DY1pWMJAx3bZIhK30KMA0GCSqGSIb3DQEBAQUABIGAg+nPsHMHkFGl
# vh1CEYJiyMx4d2FmUHvQkMcavx+XcJSw67IsaQr08Cah47xB4+0opfAtZDdlP7Vv
# XncjdlMVOWMLeFXu19OWXIDIoAn0q/UjmADZ6yNobDrceCV8JgFS1Q3rEbYpMePC
# OoxfvXWdlS40TnNEUIAOcWu4vnwxIdA=
# SIG # End signature block
