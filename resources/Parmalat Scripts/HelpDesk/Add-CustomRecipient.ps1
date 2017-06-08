Import-Module ActiveDirectory

$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
# $SysDir = "\\vc2util-02\scripts\Common"
. ($SysDir + '\vbFunctions.ps1')
. ($SysDir + '\PowerShell.ps1')
. ($SysDir + '\ParmalatData.ps1')
. ($SysDir + '\ADFunctions.ps1')
Add-Snapins


$ImportOU = 'parma.internal/Parmalat Users/HelpDeskImport'
$file = "O:\GBS\HelpDesk\Scripts\Add-newContacts.xlsm"
$mbx = $null
$contacts = Read-SpreadSheetExcel -filePath $file -SheetName "Add-NewCOntacts"

foreach ($Item in $contacts) {
	$addMailbox = $true
	if ($Item.AddressOrMobileNumber.tostring().Length -eq 9) {
		$email = "0" + $Item.AddressOrMobileNumber + "@messagenet.com.au"
		$type = "SMS Contact"
	}
	else {
		$email = $Item.AddressOrMobileNumber
		$type = "Email Address"
	}
	
	$matches = Validate-ADEmailAddress -Address $Email
	
	if ($matches -notlike "NoMatches") {
		$LogString = @"
Email Address "$Email" Alread Exists in directory.
$($matches | out-string)
Operation Halted.
"@
		msgbox -style $(msgboxstyle -IconStyle "critical") -Prompt $LogString > $null
		$addMailbox = $false
	}
	$alias = func_createusername -displayName $Item.DisplayName
	$matches = Validate-SimpleADName -alias $alias -DisplayName $Item.DisplayName
	
	if ($matches -notlike "NoMatches") {
		$Logstring = @"
Alias "$alias" or Display Name "$($Item.DisplayName)" Already Exist int he directory.
$matches
Operation Halted.
"@
		msgbox -style $(msgboxstyle -IconStyle "Critical") -Prompt $Logstring > $null
		$addMailbox = $false
	}
	
	
	
	
	if ($addMailbox -eq $true) {
		$mbx += @(New-MailContact -Name $Item.DisplayName -Alias $Alias `
			-ExternalEmailAddress $Email -OrganizationalUnit $ImportOU)
		$groups = processlist $Item.GroupstoAdd
		foreach ($group in $groups) {Add-QADGroupMember -Identity $group -Member $alias}
	}
	else {
		$mbx += @($('Mailbox "' + $Item.DisplayName + '" found in directory. Contact Not added'))
	}
}	
if ($mbx -notlike $null) {
	$LogString = @"
Process completed Succesfully

"@
	foreach ($line in $mbx) {
		$LogString += @"
$line

"@
	}
	$Logstring += @"
Operation Completed
"@
	msgbox -Prompt $LogString > $null
}

