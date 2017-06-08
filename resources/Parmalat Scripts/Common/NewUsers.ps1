Function CitrixUser-Standard {Param ($FirstName = $(Throw '-FirstName Parameter required...'),
	$LastName = $(Throw '-LastName Parameter required...'),
	$Phone,
	$Mobile,
	$Fax,
	$Site = $(Throw '-Site Parameter required...'),
	$EmpNo,
	$CC,
	$Department,
	$JobTitle,
	$MemberOf,
	$Environment = $null,
	$CopyUser,
	[Switch]$PS4GrpsOnly,
	[Switch]$AddPS4Grps,
	[Switch]$Help,
	$LogFile = '\\parma.internal\dfsroot\gbs\helpdesk\scripts\logs\Add New User Ver 3.0.log',
	$DC = $env:LOGONSERVER.trim('\'),
	$Password = 'Password1',
	$OU = 'HelpDeskImport',
	$JobNumber = $(Throw '-JobNumber Parameter Required...'),
	$credentials = $null
#	$SDPpassword = $(Throw '-SDPpassword Parameter Required...'),
#	$SDPUser = $env:USERNAME.trim("_adm").tolower()
	)
	
Trap {$Msg = $_.Exception.Message; $Line = $_.InvocationInfo.ScriptLineNumber; $cmd = $_.InvocationInfo.InvocationName
$LogString = @"
$Msg
Script Line Number: "$Line"
Command: "$Cmd"
"@
Write-EventLog -EntryType Error -EventId 3 -Message $LogString -LogName $LogFile -Source 'NewUsers.ps1'
	Switch ($_.CategoryInfo.Category){
		'OperationStopped' {Write-EventLog -EntryType Error -EventId 1 -Message 'Operation Halted' -LogName $LogFile -Source 'NewUsers.ps1'
			$ErrorActionPreference = $Errorpref
			Exit
		}
		'ADObjectAlreadyExistsException' {Write-EventLog -EntryType Error -EventId 1 -Message 'UserName Parameter is invalid.' -LogName $LogFile -Source 'Add-Users.ps1'
			$ErrorActionPreference = $Errorpref
			Exit
		}
	default {Continue}
	}
}


# Set initial Variables
Write-Host 'New Standard user'
$SAPGroups = ',"Citrix SAP Users","Citrix SAP Enjoy"'
$PS4groups = ',"Citrix PS4 Users","Citrix PS4-ParmaApps-No TimeZone"'
$Xengroups = ',"Xen Desktop Pilot","Citrix XenApp Users","Citrix XenApp Pilot Users"'
$Snapins = Get-PSSnapin
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'Microsoft.Exchange.Management.PowerShell.Admin') {$match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin}
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'quest.activeroles.admanagement') {$Match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin quest.activeroles.admanagement}
If ($Help.IsPresent -eq $true) {ShowHelp}
$FirstName = $FirstName.Substring(0,1).ToUpper() + $FirstName.Substring(1,($FirstName.Length - 1)).ToLower()
$LastName = $LastName.Substring(0,1).ToUpper() + $LastName.Substring(1,($LastName.Length - 1)).ToLower()
$DisplayName = $LastName + ', ' + $FirstName
$Description = $Department + ' - ' + $JobTitle
$Password = ConvertTo-SecureString -AsPlainText $Password -Force
$Conn = Connect-QADService -Service $($DC + '.parma.internal')
$ExcelExists = test-ExcelExists -servername $env:COMPUTERNAME

#Process Initial variables


$address = get-siteaddress -Site $Site -ExcelExists $ExcelExists
$DataStore = get-siteDataStoreDetails -Site $Site -ExcelExists $ExcelExists
If ($DataStore -eq $null) {Throw 'Data store details not found. Please check Site name....'}
$MSDomPolGrp = ',"Microsoft Domain Policy - ' + $DataStore.FS.Trim('\') + ' User Data"'
$UserName = func_createusername -FirstName $FirstName -LastName $LastName -DC $DC
$UPN = $UserName + '@parma.internal'
$Email = $FirstName.ToLower() + '.' + $LastName.ToLower() + '@parmalat.com.au'
$Email = $Email.replace(" ","")
$DataStore.UserDir += $UserName
$HomeDir = $DataStore.FS + $UserName + '$'
$TSProf = '\\fs5\data5$\profile\' + $UserName + '\win2k3'

If ($(ValidateADUser -name $DisplayName -fn $FirstName -sn $LastName -EmployeeID $EmpNo -CC $CC -logfile $LogFile -JobNumber $JobNumber -credentials $credentials) -eq $true) {Throw 'User validation failed. Operation Halted.....'}

#Add User to Exchange
Write-Host 'Adding Mailbox...'

$Mbx = New-Mailbox -DataBase $DataStore.ExDS `
	-name $DisplayName `
	-Password $Password `
	-Alias $UserName `
	-OrganizationalUnit $OU `
	-userPrincipalName $UPN `
	-ResetPasswordOnNextLogon $true `
	-DomainController $DC
$DS = $DataStore.ExDS
$LogString = @"
New User Created Succesfully
Display Name: "$DisplayName"
User Name: "$UserName"
Organizational Unit: "$OU"
User Principal Name: "$UPN"
Domain Controller: "$DC"
Exchange Store: "$DS"
"@

$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'New-Mailbox'
Write-Host 'Done!'
$SMTPAddresses = (get-mailbox -identity $Username -DomainController $DC).EmailAddresses
ForEach ($SMTPAddress in $SMTPaddresses) {
	If ((Select-String -CaseSensitive -InputObject $SMTPAddress.ProxyAddressString -Pattern 'SMTP:' -SimpleMatch) -ne $null) {
		If ($SMTPaddress.smtpaddress -like $($UserName + '@parmalat.com.au')) {
#			$ProxyAddresses = @($('SMTP:' + $Email),$('NOTES:' + $FirstName + ' ' + $LastName + '/BRISBANE/PAULS@Exchange'),$('X400:C=AU;A= ;P=PAULS;O=BRISBANE;S=' + $LastName + ';G=' + $FirstName + ';'))
			$ProxyAddresses = $('SMTP:' + $Email)
			Set-mailbox -Identity $UserName -EmailAddressPolicyEnabled $false -DomainController $DC -EmailAddresses $ProxyAddresses
		}
		Break
	}
}


# Add AD Properties
Write-host 'Modifying Active Directory...'

$Mbx = Set-QADUser -Identity $UserName `
	-City $address.Suburb `
	-Department $Department `
	-Description $Description `
	-Title $JobTitle `
	-Fax $Fax `
	-HomeDirectory $HomeDir `
	-HomeDrive 'M:' `
	-LogonScript 'lg.bat' `
	-MobilePhone $Mobile `
	-Office $($Site.Substring(0,1).ToUpper() + $Site.Substring(1,($Site.Length - 1)).ToLower()) `
	-PhoneNumber $Phone `
	-PostalCode $address.PostCode `
	-StateOrProvince $address.State `
	-StreetAddress $address.Street `
	-TsProfilePath $TSProf `
	-FirstName $FirstName `
	-LastName $LastName `
	-Connection $Conn
#	-TsInitialProgram $Environment
$path = 'LDAP://' + $DC + '.parma.internal/' + $(Get-ADUser -Identity $UserName -Server $DC).DistinguishedName
$usr = [ADSI]$path
$Usr.psbase.invokeset("employeeNumber",($EmpNo + ';' + $CC))
if ($empno -notlike $null){$usr.psbase.invokeset("employeeID",$EmpNo)}
if ($CC -notlike $null) {$usr.psbase.invokeset("departmentNumber",$CC)}
$Usr.SetInfo()
Write-Host 'Done!'
# Is user accessing PS4, Xen or Both Environments?
$Suburb = $address.Suburb; $PostCode = $address.PostCode; $State = $address.State; $Street = $address.Street
$LogString = @"
User name: "$UserName"
Phone: "$Phone"
Mobile: "$Mobile"
Fax: "$Fax"
Description: "$Description"
Department: "$Department"
Cost Centre: "$CC"
Employee Number: "$EmpNo"
Job Title: "$JobTitle"
Office: "$Site"
Home Directory: "$HomeDir"
TS Profile Path: "$TSProf"
Address:
	$Street
	$Suburb
	$State
	$PostCode
"@

$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Set-QADUser'

If ($PS4GrpsOnly.IsPresent -eq $true) {$Envs = 'PS4'}
If ($AddPS4Grps.IsPresent -eq $true) {$Envs = 'Both'}
Switch ($Envs) {
	'PS4' {$Envs = $PS4groups}
	'Both' {$Envs = $Xengroups + $PS4groups}
	default {$Envs = $Xengroups}
}
If ($MemberOf -eq $null){$groups = $Envs.Trim(',') + $MSDomPolGrp + $SAPGroups}
Else {$Groups = $MemberOf + $Envs + $MSDomPolGrp + $SAPGroups}
$groups = processlist -string $groups
$logGrps = $null
foreach ($line in $Groups) {$LogGrps = @"
$LogGrps
$line
"@}
$grpSIDs = @()
foreach ($grp in $groups) {$grpSIDs += $(Get-ADGroup -Identity $grp).SID.value}
$groups = $grpSIDs
If ($CopyUser -notlike $null) {$groups = @()
	$usrgroups = (Get-QADUser -Identity $CopyUser).Memberof
	foreach ($grp in $usrgroups) {$groups += (Get-ADGroup -Identity $grp).SID.value}
	if ($ExcelExists -eq $false) {$AuthorisedGroupslist = Read-SpreadSheetOLE -filePath \\parma.internal\dfsroot\GBS\HelpDesk\Scripts\PowerShellData.xls -SheetName 'RemoveGroups'}
	else {$AuthorisedGroupslist = Read-SpreadSheetExcel -filePath \\parma.internal\dfsroot\GBS\HelpDesk\Scripts\PowerShellData.xls -SheetName 'RemoveGroups'}
	$groups = Remove-AuthorisedGroups -InputList $Groups -logfile $LogFile -authorisedgroupslist $AuthorisedGroupslist -credentials $credentials -jobnumber $jobnumber
	$policygrpname = "Microsoft Domain Policy - " + $DataStore.FS.Trim("\") + " User Data"
	$policySID = $($AuthorisedGroupslist | where -FilterScript {$_.DisplayName -like $policygrpname}).SID
	$groups += $policySID
	
	$logGrps = $null
	foreach ($line in $groups) {$line = $(Get-QADGroup $line).name
	$LogGrps = @"
$LogGrps
$line
"@}
}


Write-Host 'Adding the following groups....'
Write-Host ''
#ForEach ($Group in $Groups) {Write-Host $group}
Write-Host $LogGrps
Write-Host ''
forEach ($group in $groups) {Add-ADGroupMember -Identity $group -Members $UserName -Server $DC}
Write-host 'Done!'
#Create User's M Drive

$LogString = @"
User added to these groups:
$LogGrps
"@

$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-ADGroupMember'

If ((Test-Path $DataStore.UserDir) -eq $false) {Write-host 'Creating M Drive: '$DataStore.UserDir
	New-Item -ItemType 'Directory' -Path $($DataStore.UserDir + '\My Documents') -Force
	Start-Sleep 10
	SetPermissions -HomePath $DataStore.UserDir -UserName $UserName
	$Result = ShareFolder -ShareDir $($DataStore.UserDir.Trim($DataStore.FS)).Replace('$',':') -ShareName $($UserName + '$') -FS $DataStore.FS.Trim('\')
	Write-host 'Done!'
	$LogString = @"
Configuring M Drive ad Permissions
Configuring share name: "$Result"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-M Drive Directory'
}

Else {Write-Host 'M Drive folder already exists. No changes made.....'
	Write-EventLog -EntryType Warning -EventId 0 -Message 'M Drive folder already exists. No changes made.....' -LogName $LogFile -Source 'Add-M Drive Directory'}
}
Function CitrixUser-Generic{Param ()}
Function CitrixUser-NoProfile {Param ()}
Function New-SharedMailBox {Param ($DisplayName = $(Throw '-DisplayName Parameter required...'),
	$Alias = $(Throw '-Alias Parameter is required...'),
	$Phone,
	$Site = $(Throw '-Site Parameter required...'),
	$CC,
	$Description = $(Throw '-Description Parameter required...'),
	$Email = $(Throw '-Email Parameter required...'),
	$Department,
	$LogFile,
	$DC = $env:LOGONSERVER.trim('\'),
	$Password = 'Password1',
	$MbxOU = 'OU=New Mailboxes,OU=Mailbox Accounts,OU=Shared Mailboxes,OU=Parmalat Users,DC=parma,DC=internal',
	$SecGrpOU = 'OU=Access Groups,' + $MbxOU,
	$AccessList,
	$JobNumber = $(Throw '-JobNumber Parameter Required...'),
	$credentials = $null
#	$SDPpassword = $(Throw '-SDPpassword Parameter Required...'),
#	$SDPUser = $env:USERNAME.trim("_adm").tolower()
	)
#  )

# Set initial Variables
Write-Host 'New Shared Mailbox'
$Snapins = Get-PSSnapin
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'Microsoft.Exchange.Management.PowerShell.Admin') {$match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin}
$match = $false
ForEach ($obj in $Snapins) {If ($obj.Name -like 'quest.activeroles.admanagement') {$Match = $true; Break}}
If ($match -eq $false) {Add-PSSnapin quest.activeroles.admanagement}
If ($Help.IsPresent -eq $true) {ShowHelp}
$DisplayName = $DisplayName.Substring(0,1).ToUpper() + $DisplayName.Substring(1,($DisplayName.Length - 1)).ToLower()
$Password = ConvertTo-SecureString -AsPlainText $Password -Force
$Conn = Connect-QADService -Service $($DC + '.parma.internal')
$SecGrpOU = $(Get-QADObject -Identity $SecGrpOU -Connection $Conn -IncludedProperties 'DistinguishedName' -SearchScope Subtree).distinguishedName

#Process Initial variables


$address = get-siteaddress -Site $Site
$DataStore = get-siteDataStoreDetails -Site $Site
$AccessList = ProcessList $AccessList
If ($DataStore -eq $null) {Throw 'Data store details not found. Please check Site name....'}
$UPN = $Email + '@parma.internal'
$Email = $Email + '@parmalat.com.au'

If ($(ValidateADUser -name $DisplayName -logfile $LogFile `
		-jobnumber $JobNumber -credentials $credentials `
		-filterstrings $("(name=*" + $alias + "*)(objectClass=Person)")) -eq $true) {
	Throw 'User validation failed. Operation Halted.....'}

#Add User to Exchange
Write-Host 'Adding Mailbox...'

$Mbx = New-Mailbox -DataBase $DataStore.ExDS `
	-name $DisplayName `
	-Password $Password `
	-Alias $Alias `
	-OrganizationalUnit $MbxOU `
	-userPrincipalName $UPN `
	-DomainController  $DC `
	-Shared
$DS = $DataStore.ExDS
$LogString = @"
Shared Mailbox Created Succesfully
Display Name: "$DisplayName"
Alias:"$Alias"
Organizational Unit: "$MbxOU"
User Principal Name: "$UPN"
Domain Controller: "$DC"
Exchange Store: "$DS"
Mailbox details:
	$Mbx
"@
$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'New-Mailbox'

Write-Host 'Done!'
$SMTPAddresses = (get-mailbox -identity $Alias -DomainController $DC).EmailAddresses
ForEach ($SMTPAddress in $SMTPaddresses) {
	If ((Select-String -CaseSensitive -InputObject $SMTPAddress.ProxyAddressString -Pattern 'SMTP:' -SimpleMatch) -ne $null) {
		If ($SMTPaddress.smtpaddress -like $($alias + '@parmalat.com.au')) {
			$ProxyAddresses = @($('SMTP:' + $Email))
			Set-mailbox -Identity $alias -EmailAddressPolicyEnabled $false -DomainController $DC -EmailAddresses $ProxyAddresses
		}
		Break
	}
}


# Add AD Properties
Write-host 'Modifying Active Directory...'
'Modifyig Active Directory Record...' | Out-File -FilePath $LogFile -Append -NoClobber

$Mbx = Set-QADUser -Identity $Alias `
	-City $address.Suburb `
	-Department $Department `
	-Description $Description `
	-Office $($Site.Substring(0,1).ToUpper() + $Site.Substring(1,($Site.Length - 1)).ToLower()) `
	-PhoneNumber $Phone `
	-PostalCode $address.PostCode `
	-StateOrProvince $address.State `
	-StreetAddress $address.Street `
	-Connection $Conn
$path = 'LDAP://' + $DC + '.parma.internal/' + $(Get-mailbox -Identity $alias -DomainController $DC).DistinguishedName
$usr = [ADSI]$path
$Usr.psbase.invokeset("employeeNumber",(';' + $CC))
$Usr.SetInfo()
Write-Host 'Done!'

$Suburb = $address.Suburb; $PostCode = $address.PostCode; $State = $address.State; $Street = $address.Street
$LogString = @"
Alias: "$Alias"
Phone: "$Phone"
Description: "$Description"
Department: "$Department"
Cost Centre: "$CC"
Office: "$Site"
Address:
	$Street
	$Suburb
	$State
	$PostCode
User Details:
	$Mbx
"@
$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Set-QADUser'

Write-Host 'Creating Full Access group...'
$groupName = $DisplayName
New-ADGroup -DisplayName $groupName -Name $GroupName -GroupCategory 1 -GroupScope 2 -Path $SecGrpOU -Server $DC
If ($AccessList -notlike $null) {Add-ADGroupMember -Identity $groupName -Members $AccessList -Server $DC}
$LogString = @"
Group Name: "$GroupName"
Organizational Unit: "$SecGrpOU"
Group Members:
$AccessList
"@
$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-ADGroup'

Write-Host 'Applying Mailbox Access Privlidges'

add-mailboxPermission  -Identity $(Get-Mailbox -Identity $Alias -DomainController $DC).DistinguishedName `
	-User $('CN=' + $groupName + ',' + $SecGrpOU) -AccessRights 'FullAccess' -DomainController $DC > $null	
Add-ADPermission -Identity $(Get-mailbox -Identity $alias -DomainController $DC).DistinguishedName `
	-User $('CN=' + $groupName + ',' + $SecGrpOU) -ExtendedRights 'Send-as' -DomainController $DC > $null
$LogString = @"
Full mailbox and Send As Access has been granted to the following group: "$GroupName"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-MailboxPermission'
return $Mbx
}
Function RoomResource-standard {Param ($DisplayName = $(Throw '-DisplayName Parameter required...'),
	$Alias = $(Throw '-Alias Parameter is required...'),
	$Phone,
	$Site = $(Throw '-Site Parameter required...'),
	$CC,
	$Description = $(Throw '-Description Parameter required...'),
	$Email = $(Throw '-Email Parameter required...'),
	$Department,
	$LogFile,
	$DC = $env:LOGONSERVER.trim('\'),
	$Password = 'Password1',
	$MbxOU = 'OU=New Mailboxes,OU=Room Resources,OU=Shared Mailboxes,OU=Parmalat Users,DC=parma,DC=internal',
	$SecGrpOU = 'OU=Access Groups,'+ $MbxOU,
	$AccessList,
	$BookingWindow = 548,
	$AutomateProcessing = 'AutoAccept',
	$ConflictPercentage = 50,
	$MaxConflicts = 30,
	$JobNumber = $(Throw '-JobNumber Parameter Required...'),
	$credentials = $null
#	$SDPpassword = $(Throw '-SDPpassword Parameter Required...'),
#	$SDPUser = $env:USERNAME.trim("_adm").tolower()
	)
# )
	$mbx = New-SharedMailBox -AccessList $AccessList `
					-Alias $Alias `
					-CC $CC `
					-DC $DC `
					-Department $Department `
					-Description $Description `
					-DisplayName $DisplayName `
					-Email $Email `
					-LogFile $LogFile `
					-MbxOU $MbxOU `
					-Password $Password `
					-Phone $Phone `
					-SecGrpOU $SecGrpOU `
					-Site $Site `
					-JobNumber $JobNumber `
					-credentials $credentials
	Set-mailbox -Identity $Mbx[1].Name -type room -DomainController $DC -UseRusServer $Mbx[1].OriginatingServer
	write-host 'Waiting for Mailbox and Calendar to Appear...'
	$starttime = Get-Date -Format HH:mm:ss
	Write-Host @"
Please Wait....
This process can take up to 10 minutes......
Process started at $starttime
"@
	$LogString = @"
Waiting for mailbox calendar discovery 
start time: $starttime

"@

	Do {$test = Get-Mailboxcalendarsettings -Identity $Mbx[1].Name -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 500} Until ($test -ne $null)
	$endtime = Get-Date -Format HH:mm:ss
	$duration = New-TimeSpan -Start $starttime -End $endtime
	$LogString += @"
End Time: $Endtime
Duration: $duration

"@
	Write-Host @"
End Time: $endtime
Duration: $duration

Mailbox found. Applying Calendar Settings

"@
	$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
	Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'new-Mailbox'

	Set-MailboxCalendarSettings -Identity $Mbx[1].Name `
					-AutomateProcessing $AutomateProcessing `
					-AllowRecurringMeetings $true `
					-BookingWindowInDays $BookingWindow `
					-ConflictPercentageAllowed $ConflictPercentage `
					-MaximumConflictInstances $MaxConflicts `
					-DomainController $DC
	
	$LogString = @"
Add-Mailbox Opration Results......
	
"@
	$string = $(Get-Mailbox -Identity $Mbx[1].DN | 
				Format-List -Property Database,`
							SAMAccountName,`
							OrganizationalUnit,`
							PrimarySMTPAddress,`
							DistinguishedName | Out-String).Trim("`r`n")
	$LogString += @"
$string

"@
	$string = $(Get-MailboxCalendarSettings -Identity $Mbx[1].DN | 
				Format-List -Property AutomateProcessing,`
							AllowConflicts,`
							BookingWindowinDays,`
							AllowRecurringMeetings,`
							ConflictPercentageAllowed,`
							MaximumConflictInstances,`
							ForwardRequestToDelegates,`
							DeleteAttachments,`
							DeleteComments,`
							RemovePrivateProperty,`
							DeleteSubject,`
							AddOrganizerToSubject,`
							TentativePendingApproval,`
							ResourceDelegates,`
							AddNewRequestsTentatively | Out-String).Trim("`r`n")
		$LogString += @"
$string

"@

							
	
$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'new-Mailbox'
Return $Mbx
}
Function RoomResource-VC{Param ($DisplayName = $(Throw '-DisplayName Parameter required...'),
		$Alias = $(Throw '-Alias Parameter is required...'),
		$Phone,
		$Site = $(Throw '-Site Parameter required...'),
		$CC,
		$Description = $(Throw '-Description Parameter required...'),
		$Email = $(Throw '-Email Parameter required...'),
		$Department,
		$LogFile,
		$DC = $env:LOGONSERVER.trim('\'),
		$Password = 'Password1',
		$MbxOU = 'OU=New Mailboxes,OU=Room Resources,OU=Shared Mailboxes,OU=Parmalat Users,DC=parma,DC=internal',
		$SecGrpOU = 'OU=Access Groups,'+ $MbxOU,
		$AccessList,
		$BookingWindow = 548,
		$AutomateProcessing = 'AutoAccept',
		$ConflictPercentage = 50,
		$MaxConflicts = 30,
		$JobNumber = $(Throw '-JobNumber Parameter Required...'),
		$credentials = $null, 
		$AdditionalResponse = $null)
	$Mbx = RoomResource-standard `
					-DisplayName $DisplayName `
					-Alias $Alias `
					-Phone $Phone `
					-Site $Site `
					-CC $CC `
					-Description $Description `
					-Email $Email `
					-Department $Department `
					-LogFile $LogFile `
					-DC $DC `
					-Password $Password `
					-AccessList $AccessList `
					-JobNumber $JobNumber `
					-credentials $credentials `
					-AutomateProcessing $AutomateProcessing `
					-BookingWindow $BookingWindow `
					-ConflictPercentage $ConflictPercentage `
					-MaxConflicts $MaxConflicts `
					-MbxOU $MbxOU `
					-SecGrpOU $SecGrpOU					
	Set-MailboxCalendarSettings -Identity $mbx[1].Name `
		-DeleteAttachments $false `
		-DeleteComments $false `
		-DeleteSubject $false `
		-AddOrganizerToSubject $false `
		-AddAdditionalResponse $true `
		-AdditionalResponse $AdditionalResponse
}
Function RoomResource-Delegate {Param ($DisplayName = $(Throw '-DisplayName Parameter required...'),
		$Alias = $(Throw '-Alias Parameter is required...'),
		$Phone,
		$Site = $(Throw '-Site Parameter required...'),
		$CC,
		$Description = $(Throw '-Description Parameter required...'),
		$Email = $(Throw '-Email Parameter required...'),
		$Department,
		$LogFile,
		$DC = $env:LOGONSERVER.trim('\'),
		$Password = 'Password1',
		$MbxOU = 'OU=New Mailboxes,OU=Room Resources,OU=Shared Mailboxes,OU=Parmalat Users,DC=parma,DC=internal',
		$SecGrpOU = 'OU=Access Groups,'+ $MbxOU,
		$AccessList,
		$BookingWindow = 548,
		$AutomateProcessing = 'AutoAccept',
		$ConflictPercentage = 50,
		$MaxConflicts = 30,
		$JobNumber = $(Throw '-JobNumber Parameter Required...'),
		$credentials = $null, 
		$AdditionalResponse = $null,
		$Delegates = $(InputBox -title 'Enter User Names' -Prompt 'Enter a comma delimited list of users that are delegates for this room (Need at least one entry)'))
	$Mbx = RoomResource-VC `
					-DisplayName $DisplayName `
					-Alias $Alias `
					-Phone $Phone `
					-Site $Site `
					-CC $CC `
					-Description $Description `
					-Email $Email `
					-Department $Department `
					-LogFile $LogFile `
					-DC $DC `
					-Password $Password `
					-AccessList $AccessList `
					-JobNumber $JobNumber `
					-credentials $credentials `
					-AutomateProcessing $AutomateProcessing `
					-BookingWindow $BookingWindow `
					-ConflictPercentage $ConflictPercentage `
					-MaxConflicts $MaxConflicts `
					-MbxOU $MbxOU `
					-SecGrpOU $SecGrpOU	`
					-AdditionalResponse $AdditionalResponse
	Set-MailboxCalendarSettings -Identity $mbx[1].Name `
		-AllBookInPolicy $false `
		-AllRequestInPolicy $true `
		-ResourceDelegates $usernames `
}



# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeAniRxe7VbKefATGQ+EVQuY6
# LlegggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FAkPqV7BWID0Jr0/R5QeIgiGIgOlMA0GCSqGSIb3DQEBAQUABIGAXdG0X3GPDc71
# Rvw76m0gYwwkOmIbcf74Z83QISPX+oPSkYP2YcBhT6QZpM3LkZEJiDbkZyeuYzns
# 7TWXENjf26XS+WbVxhMP7l/1ty63DiOgC5V8OE6y4wEVzfOWt+zeU1Ldxu0MEmTp
# F18SazQMUdpUAFgM4uAg198d55QcX2c=
# SIG # End signature block
