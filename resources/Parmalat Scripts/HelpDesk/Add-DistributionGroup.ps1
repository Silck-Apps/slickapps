Param ($alias = $null, 
	$DisplayName = $null,
	$members = $null,
	$emailPrefix = $null,
	$Description = $null,
	$credentials = $null,
	$jobnumber = $null,
	$DC = $env:LOGONSERVER.trim('\'),
	$OU = 'HelpDeskImport',
	$LogFile = "HelpDesk - New Distribution Groups",
	[switch]$RegisterEventLog)
	
Function Register-EventLog {
	New-EventLog -LogName $LogFile -Source 'Add-DistributionGroup.ps1'
	New-EventLog -LogName $LogFile -Source 'Validate-SimpleADName'
	New-EventLog -LogName $LogFile -Source 'New-DistributionGroup'
	New-EventLog -LogName $LogFile -Source 'Get-DistributionGroup'
	Exit
}
		
$Error.Clear()
$Conn = Connect-QADService -Service $($DC + '.parma.internal')
if ($RegisterEventLog.IsPresent -eq $true) {Register-EventLog}

Import-Module ActiveDirectory
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\ParmalatData.ps1')
. ($SysDir + '\vbFunctions.ps1')
. ($SysDir + '\PowerShell.ps1')

if ($alias -like $null) {$alias = $(InputBox -Prompt "Please Enter an Alias for the new group" -title "Enter Alias (Required)")}
if ($DisplayName -like $null) {$displayname = $(InputBox -Prompt "Please Enter the Display Name for this group" -title "Enter Display Name (Required)")}
if ($members -like $null) {$members = $(InputBox -prompt $('Please enter a Comma delimited list (EG: "Value1","value2","value3") of users to be added. ' + `
			'You can use usernames or display names (or a mixture of both) for this list.') -title "Please enter group members (Required)")}
if ($emailPrefix -like $null) {$emailPrefix = $(InputBox -prompt 'Please enter the email prefix (The bit that goes before "@parmalat.com.au")' -title "Enter email prefix (Required)")}
if ($Description -like $null) {$Description = $(InputBox -prompt "Please enter description for Active Directory" -title "Please enter Description (Optional)")}
#if ($SDPpassword -like $null) {$SDPpassword = $(InputBox -prompt "Please enter your SDP password" -title "Enter SDP password (Optional)")}
if ($credentials -like $null) {$credentials = $Host.ui.PromptForCredential("Enter SDP Credentials", "Please enter your Service Desk Plus credentials", $env:USERNAME.trim("_adm"),"")}
if ($jobnumber -like $null) {$jobnumber = $(InputBox -prompt "Please enter the SDP job number" -title "Enter SDP Job Number (Optional)")}


if (($alias -like $null) -or ($DisplayName -like $null) -or ($members -like $null) -or ($emailPrefix -like $null)) {
	$LogString = @"
Some required details were not completed. Operation halted. 
Please try again
"@
	$result = MsgBox -Prompt $LogString -title "Operation Stopped" -style $(msgboxstyle -IconStyle "critical")
	$LogString = SDP_Log -jobnumber $jobnumber -LogString $LogString -credentials $credentials
	Write-EventLog -EntryType Error -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-DistributionGroup.ps1'
	Exit
}
else {
	$LogString = @"
All Required Details have been completed.
Continue?
"@
	$result = MsgBox -Prompt $LogString -title "Shall we continue?" -style $(msgboxstyle -buttons YesNo -IconStyle Information)
	If ($result -like "no") {
		$LogString += @"
	
User ($env:USERNAME) chose not to continue.
Operation Halted
"@
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-DistributionGroup.ps1'
		Exit
	}
	else {
		$LogString += @"
		
User ($env:USERNAME) chose to continue.
Continuing.....
"@
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-DistributionGroup.ps1'
	}
}
$validationresult = Validate-SimpleADName -alias $alias -DisplayName $DisplayName
if ($validationresult -notlike 'NoMatches') {
	$LogString = @"
Groups were found with matching details

$($validationResult | ft -property alias,displayname,DN -autosize | out-string)

Operation Halted
"@
	$result = $(msgbox -Prompt $LogString -title "Matches Found" -style $(Msgboxstyle -IconStyle warning))
	$LogString = SDP_Log -jobnumber $jobnumber -LogString $LogString -credentials $credentials
	Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Validate-SimpleADName'
	exit
}
else {
	$members = processlist -string $members
	$LogString = @"
The following details are being used to create the new Distribution group:
Alias: $alias
DisplayName: $displayname
Email address: $($emailprefix + "@parmalat.com.au")
Description: $description
Group Members:

"@
	foreach ($line in $members) {$LogString += @"
 - $line

"@}
	$LogString = SDP_Log -jobnumber $jobnumber -LogString $LogString -credentials $credentials
	Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'New-DistributionGroup'
	$group = New-DistributionGroup -Alias $alias -DisplayName $DisplayName -DomainController $DC -Name $DisplayName `
		-OrganizationalUnit $OU -Type Distribution -SamAccountName $alias
	Set-DistributionGroup -Identity $group.Name -DomainController $DC -EmailAddressPolicyEnabled $false `
		-PrimarySmtpAddress $($emailPrefix + "@parmalat.com.au")
	Set-QADGroup -identity $group.Name -Member $members -Connection $conn -Description $Description > $null
	$group = Get-QADObject -Identity $group.Name -Connection $Conn
	if ($group -like $null) {
		$LogString = @"
Could not find the group after addition. Operation Failed

"@
		$result = $(msgbox -Prompt $LogString -title "Operation Failed" -style $(Msgboxstyle -IconStyle warning))
		$LogString = SDP_Log -jobnumber $jobnumber -LogString $LogString -credentials $credentials
		Write-EventLog -EntryType Error -EventId 0 -Message $LogString -LogName $LogFile -Source 'Get-DistributionGroup'
	}
	else {
		$LogString = @"
The following details were added to Active Directory	
Alias: $($group.alias)
Display Name: $($group.displayname)
Description: $($group.description)
email address: $($group.primarysmtpaddress)
Group Members:

"@
		foreach ($line in $group.members) {
			$name = $(Get-QADObject -Identity $line).Name
			$LogString += @"
 - $name

"@
		}
		$result = $(msgbox -Prompt $LogString -title "Operation Completed" -style $(Msgboxstyle -IconStyle information))
		$LogString = SDP_Log -jobnumber $jobnumber -LogString $LogString -credentials $credentials
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Get-DistributionGroup'
	}
}