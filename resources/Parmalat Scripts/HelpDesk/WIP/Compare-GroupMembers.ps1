Param ($Group = $null, 
	[switch]$FirstRun, 
	$Path = "\\parma.internal\dfsroot\GBS\helpdesk\scripts\GeneratedData-Temp\")
cls
function set-ScriptsDir {param ($ScriptPath, $testDir = "HelpDesk")
$ScriptsDir = $null
$filepath = $($ScriptPath).split("\")
$i = 0
foreach ($Item in $filepath) {
	If ($Item -like $testDir) {$endcell = $i; break}
	$i++
}
$startcell = 0
if ($filepath[0] -like $null) {$startcell = 2; $Scriptsdir = "\\"}
for ($i = $startcell; $i -le $endcell; $i++ ) {If ($i -eq $startcell) {$ScriptsDir += $filepath[$i]}
	else {$ScriptsDir += "\" + $filepath[$i]}
	}
Return $ScriptsDir
}
Function Create-Spreadsheet {Param ($Excel)
	$WB = $Excel.WorkBooks.Add()
	$WS = $WB.WorkSheets.Item(1)
	$WS.Name = "Users Added to Group"
	$WS = $WB.WorkSheets.item(2)
	$WS.Name = "Users Removed from the group"
	$WS = $WB.WorkSheets.item(3)
	$WS.Name = "Previous Group Membership"
	Return $WB, $Excel
}
Function Write-GroupListingHeaders {Param ($WS, $FNCol, $LNCol, $SIDCol, $UNCol, $DateCol = $false, $r)
$select = $WS.Cells.Item($r,$LNCol)
$select.Value2 = "FirstName"
$select = $WS.Cells.Item($r,$FNCol)
$select.Value2 = "LastName"
$select = $WS.Cells.Item($r,$SIDCol)
$select.Value2 = "SID"
$select = $WS.Cells.Item($r,$UNCol)
$select.Value2 = "SamAccountName"
if ($DateCol -ne $false) {$select = $WS.Cells.Item($r,$DateCol); $select.Value2 = "Date"}
}
Function Enter-List { Param ($list, $r, $FNCol, $LNCol, $SIDCol, $UNCol, $DateCol = $false)
	$originalr = $r
	foreach ($entry in $list) {
		$cell = $WS.Cells.item($r,$FNCol); $cell.value2 = $entry.FirstName
		$cell = $WS.Cells.item($r,$LNCol); $cell.value2 = $entry.LastName
		$cell = $WS.Cells.item($r,$SIDCol); $cell.value2 = [string]$entry.SID
		$cell = $WS.Cells.item($r,$UNCol); $cell.value2 = $entry.SAMAccountName
		$r++}
	$r = $originalr	
	If ($DateCol -ne $false) {$date = $(Get-Date); $WS.Columns.item($DateCol).NumberFormat = "dd/mm/yyyy"
		foreach ($entry in $list) {$cell = $WS.Cells.item($r,$DateCol); $cell.value2 = $Date}
	}
}
Function Prepare-SpreadSheet { Param ($Group, $filepath, $Excel)
	. ($SysDir + "\PowerShell.ps1")
	$list = @()
	foreach ($Usr in $(Get-QADGroup $Group).Members) {$list += Get-QADUser $Usr}
	$WB, $Excel = Create-Spreadsheet -Excel $Excel
	$WS = $WB.Worksheets.item("Previous Group Membership")
	$select = $WS.Cells.Item(1,1)
	$select.Value2 = "Previous Group Membership as of: " + $(Get-Date)
	Write-GroupListingHeaders -WS $WS -FNCol $FNCol -LNCol $LNCol -SIDCol $SIDCol -UNCol $UNCol -r 2 
	Enter-List -list $list -r 3 -FNCol $FNCol -LNCol $LNCol -UNCol $UNCol -SIDCol $SIDCol 
	$WS = $WB.Worksheets.Item("Users Added to Group")
	Write-GroupListingHeaders -DateCol $DateCol -FNCol $FNCol -LNCol $LNCol -r 1 -SIDCol $SIDCol -UNCol $UNCol -WS $WS
	$WS = $WB.Worksheets.Item("Users removed from the Group")
	Write-GroupListingHeaders -DateCol $DateCol -FNCol $FNCol -LNCol $LNCol -r 1 -SIDCol $SIDCol -UNCol $UNCol -WS $WS
	$WB.SaveAs($filepath,18)
	$WB.Close()
	$Excel.quit()
	Exit
}
if ($Group -like $null) {Throw "Group parameter not specified. Exiting now."}
else {if ($(Get-QADGroup $Group) -like $null) {Throw "Group specified dosen't exist. Exiting Now."}}
$names = @()
#$Excel = New-Object -ComObject Excel.application
#$Excel.DisplayAlerts = $false
#$Excel.visible = $false
$ScriptsDir = set-ScriptsDir $MyInvocation.MyCommand.Path
$SysDir = $ScriptsDir + "\System"
. ($SysDir + "\ADFunctions.ps1")
. ($SysDir + "\ParmalatData.ps1")
$filepath = '"' + $path + $Group + ' Group Membership Details.xls"'
$FNCol = 1; $LNCol = 2; $SIDCol = 3; $UNCol = 4; $DateCol = 5
If ($FirstRun.IsPresent -eq $true) {Prepare-SpreadSheet -Group $Group -filepath $filepath -Excel $Excel}
#$WB = $Excel.Workbooks.open($FilePath)
#$WS = $WB.Worksheets.item("Previous Group Membership")
$list = Read-SpreadSheet -filePath $filePath -SheetName "Previous Group Membership" # -qry 'SELECT SID from [**value**$]'
$count = $List.Count
#$SIDS = @()
#for ($r = 3; $r -le $count; $r++  ) {
#	$SIDS += $WS.Cells.Item($r,$SIDCol).value()
#}
$names = @()
foreach ($usr in $list) {$names += $(Get-QADUser $usr.SID)}

$matches, $listonly, $Grouponly = Compare-ADGroupMembership -Group $Group -names $names
if ($matches -notlike $null) {
#	$WS.Delete()
#	$WS = $WB.WorkSheets.Add()
#	$WS.Name = "Previous Group Membership"
#	$WS = $WB.Worksheets.item("Previous Group Membership")
#	$select = $WS.Cells.Item(1,1)
#	$select.Value2 = "Previous Group Membership as of: " + $(Get-Date)
#	Write-GroupListingHeaders -WS $WS -FNCol $FNCol -LNCol $LNCol -r 2 -SIDCol $SIDCol -UNCol $UNCol
#	Enter-List -FNCol $FNCol -list $matches -LNCol $LNCol -r 3 -SIDCol $SIDCol -UNCol $UNCol






}
if ($grouponly -notlike $null) {
	Enter-List -FNCol $FNCol -list $grouponly -LNCol $LNCol -r ($WS.UsedRange.Rows.count + 1) -SIDCol $SIDCol -UNCol $UNCol
	$WS = $WB.Worksheets.Item("Users Added to Group")
	Enter-List -FNCol $FNCol -list $grouponly -LNCol $LNCol -r ($WS.UsedRange.rows.count + 1) -SIDCol $SIDCol -UNCol $UNCol -DateCol $DateCol
}
if ($listonly -notlike $null) {
	$WS = $WB.worksheets.Item("Users Removed from the group")
	Enter-List -DateCol $datecol -FNCol $FNCol -list $listonly -LNCol $LNCol -r ($WS.UsedRange.rows.count + 1) -SIDCol $SIDCol -UNCol $UNCol
}
$WB.Save()
$WB.Close()
$Excel.Quit()
Exit
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHUg6mEr/gxrDgoX5+YxIPnHu
# gwygggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FCYPwWzKtVO2a5NouB5sTc4RytcsMA0GCSqGSIb3DQEBAQUABIGAHcQ3g7jEqDc5
# rNil1jbmbSSTL7MWz061AGCj7t8tL5Fu/fa6tUd9QkU3rMZfxAjO5x2fGf1+QH/z
# 3kPcDQUO5/zS0aWHKRK/4wS0y+ABPTpGFrPjKwScTqnEzXHt1+TJ+fFKhssFApff
# KHgXtWx6ApdJp0pDtK0cstBQittU8o8=
# SIG # End signature block
