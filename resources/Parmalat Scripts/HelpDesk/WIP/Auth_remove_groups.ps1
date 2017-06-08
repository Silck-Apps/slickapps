$Error.Clear()
Clear-Host
$ss = Read-SpreadSheet -filePath O:\GBS\HelpDesk\Scripts\PowerShellData.xls -SheetName RemoveGroups
$data = @()
foreach ($entry in $ss) {
	$obj = Get-QADObject $entry.DisplayName
	if ($obj.Description -notlike $Null) {$description = $obj.Description -replace [Environment]::NewLine," "} else {$description = $null}
	if ($obj.Notes -notlike $null) {$notes = $obj.Notes -replace [Environment]::NewLine," "} else {$notes = $null}
	[string]$Comments = $description + " " + $notes
	$data += New-Object -TypeName PSObject -Property @{
			DisplayName = $entry.DisplayName;
			SID = $obj.SID.value;
			Controls = $entry.Controls;
			Comments = $comments
	}
}
$data | ConvertTo-Csv -NoTypeInformation > 'M:\My Documents\Scratch\some.csv'