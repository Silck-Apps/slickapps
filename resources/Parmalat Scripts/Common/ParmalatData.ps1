Function Validate-SimpleADName {Param ($alias, $DisplayName)
	$testalias = Get-QADObject -Identity $alias
	$testdisplayname = Get-QADObject -Identity "*$DisplayName*"
	if (($testalias -like $null) -and ($testdisplayname -like $null)) {$result = "NoMatches"}
	else {$result = @($testalias,$testdisplayname) | sort -Unique}
	Return $result
}

function Get-OrgChartsData {
	$OrgChartPRD = "\\parma.internal\dfsroot\OSINT\PRD\HR\charts"
	$CSVData = @()
	$OrgChartsData = @()
	$files = Get-ChildItem $OrgChartPRD
	foreach ($file in $files) {
		$data = Get-Content -Path $file.FullName
		foreach ($line in $data) {
			$line = $line.trim('"')
			$line = $line.split('","')
			$CSVData += $('"' + $line[6] + '","' + $line[15] + '","' + $line[18] + '","' + $line[27] + '"')
			}			
		}
	foreach ($line in $CSVData) {
		$line = $line.trim('"')
		$line = $line.split('","')
		$OrgChartsData += New-Object -Typename PsObject -Property @{
			Department = $line[0]
			LastName = $line[3]
			FirstName = $line[6]
			Position = $line[9]
			}
		}
	Return $OrgChartsData
}
Function Read-SpreadSheetOLE {Param ($filePath, $SheetName,
	$qry = "SELECT * from [**value**$]")
	$connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";"
	$connString = $connString.replace('""','"')
	$qry = $qry.replace("**value**",$SheetName)
	$conn = new-object System.Data.OleDb.OleDbConnection($connString)
	$conn.open()
	$cmd = new-object System.Data.OleDb.OleDbCommand($qry,$conn) 
	$da = new-object System.Data.OleDb.OleDbDataAdapter($cmd) 
	$dt = new-object System.Data.dataTable 
	[void]$da.fill($dt)
	$conn.close()
	if ($error.count -ne 0) {Throw "Sheet Name not found"; Exit}
	Return $dt.Rows
}

Function Read-SpreadSheetExcel {Param ($filePath, $SheetName)
$headers = $null; $list = $null; $data = $null
	$ExcelApp = New-Object -ComObject excel.application
	$ExcelApp.Visible = $false
	$Workbook = $ExcelApp.workbooks.open($filePath)
	$worksheet = $Workbook.worksheets.item($SheetName)
	$headers = $worksheet.Rows.item(1).value()
	foreach ($Item in $headers) {if ($Item -notlike $null) {$list += @($Item)}}
	$totalcolumns = $list.Count
	$row = 2
	Do {
		$data += @(New-Object -TypeName PSObject)
		foreach ($Item in $list) {Add-Member -InputObject $data[($row - 2)] -MemberType NoteProperty -Name $Item -Value $null}
		$column = 1
		Do {
			$data[($row - 2)].($list[($column - 1)]) = $worksheet.Cells.Item($row, $column).value()
			$column++
		}
		While ($column -le $totalcolumns)
		
	$row++
	}
	While ($worksheet.rows.item($row).value() -ne $null)

	$ExcelApp.Quit()
	Release-Ref -ref $worksheet > $null
	Release-Ref -ref $Workbook > $null
	Release-Ref -ref $ExcelApp > $null
	
	Return $Data
}

Function test-ExcelExists {Param ($servername = $null)
	if ($servername -eq $null) {Throw "Must specify the server to test"; exit}
	$test = Get-WmiObject -ComputerName $servername -Namespace root\CIMV2 -Class Win32_Product |
		where -FilterScript {$_.name -like "*excel*"}
	if ($test -like $null) {$result = $false}
	else {$result = $true}
	Return $result
}
Function Connect-SpreadSheet {Param ($filePath, $SheetName)
	$connString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";" #64
	$qry = "SELECT * from [$SheetName$]"
	$conn = new-object System.Data.OleDb.OleDbConnection($connString)
	$conn.open()
	$cmd = new-object System.Data.OleDb.OleDbCommand($qry,$conn) 
	$da = new-object System.Data.OleDb.OleDbDataAdapter($cmd) 
	$dt = new-object System.Data.dataTable 
	Return $conn
}

Function WriteTo-Spreadsheet { Param ($filePath, $Data)
$strProvider = "Provider=Microsoft.ACE.OLEDB.12.0"
$strDataSource = "Data Source ="+$filepath
$strExtend = "Extended Properties=Excel 12.0 Xml"
$strQuery = "Insert into [Shares$] (LastName,FirstName,SID,SamAccountName) Values ($Data)"
$objConn = new-object System.Data.OleDb.OleDbConnection( ` "$strProvider;$strDataSource;$strExtend")
$sqlCommand = new-object System.Data.OleDb.OleDbCommand($strQuery)
$sqlCommand.Connection = $objConn


$LastNameParam = $sqlCommand.parameters.add("LastName","VarChar",80)
$FirstNameParam = $sqlCommand.parameters.add("FirstName","VarChar",80)
$SIDParam = $sqlCommand.parameters.add("SID","VarChar",80)
$SAMaccountNameParam = $sqlCommand.parameters.add("SamAccountName","VarChar",80)
$objConn.open()

ForEach($rec in $Data)
{
  $aReturn = $LastNameParam.value = $share.name
  $breturn = $FirstNameParam.value = $share.path
  $cReturn = $SIDParamParam.value = $share.Description
  $dReturn = $SamAccountNameParam.value = $share.Type
  $returnValue = $sqlCommand.ExecuteNonQuery()
}
$objConn.close()
}
Function Remove-AuthorisedGroups {Param ($credentials, $jobnumber, $inputlist, $LogFile, $AuthorisedGroupslist)

#$Error.Clear()

function listgroups {Param ($groups)
	$LogGrps = $null
	foreach ($line in $groups) {$name = $(get-qadgroup $line.SID).name
								$description = $(Get-QADGroup $line.SID).description
								$info = $(Get-QADObject $Line.SID).notes
								$LogGrps += @"
Group name: $name
	Description: $Description
	Info: $Info

"@
#		$LogGrps = @"
#$LogGrps
##$line
#"@
}
Return $LogGrps
}


$GPOgroups = @(); $FolderAccessGroups = @(); $ObsoleteGroups = @(); $SoftwareGroups = @(); $PubAppsGroups = @(); $ExchGroups = @()


$AuthGroupSIDs = @()
foreach ($SID in $AuthorisedGroupslist) {$AuthGroupSIDs += $SID.SID}
$removegroups = Compare-Object $inputlist $AuthGroupSIDs -IncludeEqual -ExcludeDifferent
$removegroupsSIDs = @()
foreach ($grp in $removegroups) {$removegroupsSIDs += $grp.InputObject}
$inputlistSIDs = @()
$outputSIDs = compare $Inputlist $removegroupsSIDs

foreach ($group in $removegroupsSIDs) { 
	$group = $AuthorisedGroupslist | where -FilterScript {$_.SID -like $group}
	Switch ($group.controls) {
		"GPO" {$GPOgroups += $group}
		"FolderAccess" {$FolderAccessGroups += $group}
		"Obsolete" {$ObsoleteGroups += $group}
		"Software" {$SoftwareGroups += $group}
		"PublishedApps" {$PubAppsGroups += $group}
		"Exchange" {$ExchGroups += $group}
	}
}

$GPOgroups = listgroups $GPOgroups
$FolderAccessgroups = listgroups $FolderAccessgroups
$Obsoletegroups = listgroups $Obsoletegroups
$Softwaregroups = listgroups $Softwaregroups
$PubAppsgroups = listgroups $PubAppsgroups
$Exchgroups = listgroups $Exchgroups


$LogString = @"
The following groups were removed...
****Citrix features******
$GPOgroups

******** Folder Access Groups **********
$FolderAccessgroups

******** Obsolete groups *******
$Obsoletegroups

*********  Licenced Software ********
$Softwaregroups

******** Published Apps ********
$PubAppsgroups

******** Exchange Server Features **********
$Exchgroups
"@

$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Remove-AuthorisedGroups'

###########################
# Enter notes into SDP Here
################################

$outputlist = @()
foreach ($SID in $OutputSIDs) {$outputlist += $SID.InputObject}
Return $Outputlist
}
Function SDP_Log {Param ($jobnumber, $LogString, $credentials)
	$response = SDP_Add_Notes -jobnumber $jobnumber -Notes $logstring -credentials $credentials
	[string]$string = $response.operation.message
	if ($response.operation.operationstatus -like "success") {
	$LogString += @"


$string to Service Desk Plus
"@
}
	else {
	$LogString += @"
	
	
Notes Addition failed for Job $jobnumber
$string
"@
}
Return $LogString
}
Function Add-ResourceConfig {Param ($newprops = $null)
	$props = @($(Get-ResourceConfig).ResourcePropertySchema)
	If ($newprops -eq $null) {Throw "No new properties supplied"}
	else {
		$props += @($newprops)
		Set-ResourceConfig -ResourcePropertySchema $props
	}
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkRmyfEppvj/QHZqnCVhWiAzG
# dy+gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FJ8s/FuXtvDZ1jW281+62oWT17EBMA0GCSqGSIb3DQEBAQUABIGAMdCwgvYpBwcS
# 5qkgrLcflhccFPR2/FVhp+dcFj6oJ4c8Zor0INqgCdkgJBow2kqvORkclfau4C8E
# 6gJu90fFxmQXZZ0b7de429c7Y0hjIyFGDFhT8wCEsH1MssqJGFbuhLnx12fO0oZ/
# d3gEUtBl9DWCXliB2mV7c2Mnf11Clw8=
# SIG # End signature block
