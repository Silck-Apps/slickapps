Param ($username = $null ,
			$Objecttype = @("citrix-SSOSecret","citrix-SSOConfig"),
			$RegKey = "\Software\Citrix\MetaFrame Password Manager",
			$LogFile = "Citrix Password Manager Reset",
			[switch]$RegisterEventLog)

Import-Module ActiveDirectory
Add-PSSnapin Quest.ActiveRoles.ADManagement
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\vbfunctions.ps1')
. ($SysDir + '\SDP.ps1')
. ($SysDir + '\citrixfunctions.ps1')
. ($SysDir + '\WMIfunctions.ps1')
. ($SysDir + '\ParmalatData.ps1')

cls
$username = InputBox -default $env:USERNAME -Prompt "Please enter the username to cleanup" -title "Please Enter Username (Required)"
$CitrixSessions = $null
$CitrixSessionsCount = $null
$objectypestring = '"' + $Objecttype[0] + '" and "' + $Objecttype[1] + '"'
If ($username -eq $null) {Throw "Username Must be specified"}
else {$ADObject = Get-QADObject $username}
$cred = $Host.ui.PromptForCredential("Enter SDP Credentials", "Please enter your Service Desk Plus credentials", $env:USERNAME.replace("_adm",""),"")
#$choice = msgbox -Prompt 'Please Enter your SDP Password in the next window' -title "SDP Password (Optional)" -style $(MsgBoxStyle -IconStyle "Information") > $null
#$SDPpassword = Inputbox -prompt "Enter your SDP password" -title "SDP Password required"
#$SDPuser = $env:USERNAME.trim("_adm")
#$choice = msgbox -Prompt 'Please Enter the SDP job Number in the Next window' -title "SDP Job number (Optional)" $(MsgBoxStyle -IconStyle "Information") > $null
$JobNumber = Inputbox -Prompt "Please enter the SDP Job Number" -title "Job number Required"
	
#Function active_removal {Param ($LogonServer = $null, $UserSID = $null, $RegKey = $null)
#}
Function Register-EventLog {
	New-EventLog -LogName $LogFile -Source 'Remove-ADObject'
	New-EventLog -LogName $LogFile -Source 'Active-UserSessions'
	New-EventLog -LogName $LogFile -Source 'AutomatedLogoff'
	New-EventLog -LogName $LogFile -Source 'Continue-ToOfflineMode'
	New-EventLog -LogName $LogFile -Source 'Get-CitrixSessions'
	New-EventLog -LogName $LogFile -Source 'Remove-RegistryKey'
	Exit
}
Function offline_removal {Param ($username = $null, $mountPath = "HKLM\Mount", $ProfileShare = "\\FSXen\xenprofile$\")
	$folders = Get-ChildItem -Path $profileShare | Where -FilterScript {$_.BaseName -like $($username + ".*")}
	$LogString = $null
	foreach ($folder in $folders) {
		$ntuser = Get-Item $($folder.FullName + "\ntuser.dat") -Force
		if ($ntuser -notlike $null) {
			$action = reg load $mountPath $ntuser.FullName
			$LogString += @"
Attempting to load user registry "$ntuser" result:
$action

"@
			$errPref = $ErrorActionPreference
			$ErrorActionPreference = "SilentlyContinue"
			$qry = reg query $($mountPath + $RegKey)
			$ErrorActionPreference = $errPref
			if ($qry -notlike $null) {
				$action = reg delete $($mountPath + $RegKey) /f
				$LogString += @"
Attempting to Delete "$($mountPath + $RegKey)" result:
$action

"@
			}
			else {
				$LogString += @"
Registry Key not found in file registry file

"@
			}
			$action = reg unload $mountPath
			$LogString += @"
Attempting to unload file registry file Result:
$action


"@
		}
	
	}
	$result = MsgBox -Prompt $LogString -title "Registry editing results" -style $(MsgBoxStyle -IconStyle "Information")
	$LogString = SDP_Log -jobnumber $JobNumber -credentials $cred -LogString $LogString
	Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Remove-RegistryKey'
}
$LogString = @"
Process started by $env:USERNAME

"@
If ($RegisterEventLog.IsPresent -eq $true) {Register-EventLog}
$UserDN = $ADObject.DN; $UserSID = $ADObject.Sid.Value
$properties = $null
foreach ($type in $Objecttype) {
	$properties += Get-QADObject -SearchRoot $UserDN -ErrorAction SilentlyContinue | 
		where -FilterScript {$_.ObjectClass -like $type}
}
$Propstring = $null
if ($Properties -notlike $null) {
	foreach ($property in $properties) {
		$propString += @"
$($property.Name)

"@
		Remove-QADObject -Identity $property.DN -force
	}
}
if ($propString -notlike $null) {
	$LogString += @"
Removed the following properties of type $objectypestring from Object "$ADObject"
$propstring

"@
}
else {
	$Logstring += @"
No AD Properties found of type $objecttypestring for user "$($ADObject.Name)"......
Nevertherless, we cary on regardless.....

"@
}
$LogString = SDP_Log -jobnumber $JobNumber -credentials $cred -LogString $LogString
MsgBox -Prompt $LogString -title "AD Operation Results" > $null
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Remove-ADObject'
$properties = $null
foreach ($type in $Objecttype) {
	$properties += Get-QADObject -SearchRoot $UserDN -ErrorAction SilentlyContinue | 
		where -FilterScript {$_.ObjectClass -like $Objecttype}
	}
if ($properties -notlike $null) {
	$propstring = $null
	foreach ($property in $properties) {
		$propString += @"
$($property.Name)

"@
	}
	$LogString = @"
Properties of type $Objecttype still found for $ADObject
$Propstring

Do You want to Continue??

"@
	$Choice = MsgBox -style $(msgboxstyle -buttons YesNo -IconStyle Warning) -Prompt $LogString -title "Warning!!"
	if ($Choice -like "No") {
		$LogString += @"
User chose not to continue. Process Terminated
"@
		Write-EventLog -EntryType Warning -EventId 0 -Message $LogString -LogName $LogFile -Source 'Remove-ADObject'
		Exit
	}
	else {
		$LogString += @"
User chose to continue.....
"@
		Write-EventLog -EntryType Error -EventId 0 -Message $LogString -LogName $LogFile -Source 'Remove-ADObject'
		$Return = MsgBox -Prompt "Please Visually double check the AD account and remove any remaining Properties. Click OK to continue" `
			-title "Please check Active Directory" -style $(msgboxstyle -IconStyle "critical")
	}
}
$CitrixSessions = Get-CitrixSessions -username $username -jobnumber $JobNumber -credentials $cred
Switch ($CitrixSessions.GetType().Name) {
	("String") {$count = 0}
	("ManagementObject") {$count = 1}
	default {$count = $CitrixSessions.count}
}
$serverstring = $null
$ServersFound = $null
foreach ($session in $CitrixSessions) {
	$ServersFound += @($session.ServerName)
}
$ServersFound = $ServersFound | sort -Unique
foreach ($entry in $ServersFound) {
	$serverstring += @"
$entry

"@
}
#	Switch ($CitrixSessionsCount) {
#		(1) {Invoke-Command -ScriptBlock {Remove-Item $("HKU:\" + $UserSID + "\" + $RegKey)} `
#				-ComputerName $CitrixSessions.Server -Credential $cred}
#		(0) {offline_removal -username $username}
#		default {$Choice = MsgBox  -style 51 -Prompt @"
#$($CitrixSessionsCount) Active Sessions detected for "$($CitrixSessions.Name)"
#$ServerString
#We will be able to deal with one active session soon (I hope!)
#Please log this session off to continue.....
#Click Yes to Continue and No to Cancel
#"@}
#	}
if ($CitrixSessions -notlike "NoMatches") {
	$Choice = $null
	$LogString = @"
$($CitrixSessions.Count) Active Sessions detected for "$username" on these servers:
$ServerString

"@
	$Choice = MsgBox  -style $(MsgBoxStyle -buttons "OKCancel" -IconStyle "Information") -title "Active Sessions Detected" -Prompt @"
$LogString
We will be able to deal with one active session soon (I hope!)
The Script will now attempt to log the sessions off that have been found
Click OK to Continue or Cancel to Halt.
"@
	Do {
		if ($Choice -like "Cancel") {
			Exit
		} 
		else {
			$ResultString = $null
			foreach ($session in $CitrixSessions) {
				$ServerName = $(Make-friendlylist $session).ServerName
				$err = $ErrorActionPreference
				$ErrorActionPreference = 'SilentlyContinue'
				$Result = $session.Logoff()
				$ErrorActionPreference = $err
				Switch ($Result.ReturnValue) {
					(0) {$Resultstring += @("Logoff Success for $username with session ID $($Session.SessionID) on Server: $ServerName")}
					(1) {$Resultstring += @("Logoff Failed for $username with session ID $($Session.SessionID) on Server: $ServerName")}
				}
			}
			If ($ResultString -notlike $null) {
				$logoffresults = $null
				foreach ($line in $ResultString) {
					$logoffresults += @"
$line

"@
				}
				$LogString = @"
Automatic Logoff Results:
$logoffresults

"@
			}
			$Result = msgbox -Prompt $LogString -title "Auto Logoff Results"
			$LogString = SDP_Log -jobnumber $JobNumber -credentials $cred -LogString $LogString
			Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'AutomatedLogoff'
			$CitrixSessions = $null
			$CitrixSessions = Get-CitrixSessions -username $username
			Switch ($CitrixSessions.GetType().Name) {
				("String") {$count = 0}
				("ManagementObject") {$count = 1}
				default {$count = $CitrixSessions.count}
			}
		}
		If ($count -gt 0) {
			$serverstring = $null; $ServersFound = $null
			foreach ($session in $CitrixSessions) {
				$ServersFound += @($session.ServerName)
			}
			$ServersFound = $ServersFound | sort -Unique
			foreach ($entry in $ServersFound) {
				$serverstring += @"
$entry

"@
			}
			$LogString = @"
$Count Active Sessions detected for "$username"
$ServerString

Auto Logoff already attempted:
$logoffresults

"@
			$Choice = MsgBox  -style $(msgboxstyle -buttons "RetryCancel" -IconStyle "Information") -title "Active Session Detected" -Prompt @"
$LogString

If you choose to Retry auto logoff will be re-attempted.
Click Retry to Continue or Cancel to Halt.
"@
			$LogString = SDP_Log -jobnumber $JobNumber -credentials $cred -LogString $LogString
			Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Active-UserSessions'
		}
	} Until ($Count -eq 0)
}
$LogString = @"
$count Active Sessions found for $username.	

Continuing in Offline Cleanup Mode.

"@
$Choice = MsgBox -style $(MsgBoxStyle -IconStyle "Information") -title "No Active Sessions Found" -Prompt $LogString
$LogString = SDP_Log -jobnumber $JobNumber -credentials $cred -LogString $LogString
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Continue-ToOfflineMode'
offline_removal -username $username