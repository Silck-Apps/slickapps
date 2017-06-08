Function Get-CitrixSessions {Param ([switch]$IncludePS4Sessions, $username = $null, $jobnumber, $credentials,
											$LogFile = "Citrix Password Manager Reset")
	$starttime = Get-Date -Format HH:mm:ss
	$Error.Clear()
	$list = $null
	$NoMatches = $null	
	$sessions = $null
	$deviceDetails = 'O:\GBS\HelpDesk\Scripts\Device Details.xlsx'
	Write-Host 'Getting active citrix server list.'
	Write-host 'Please sit back, relax and let your mind wander!.....'
	Write-Host ''
	if ($IncludePS4Sessions.IsPresent -eq $true) {
		$ExcelExists = test-ExcelExists -servername $env:COMPUTERNAME
		if ($ExcelExists -eq $false) {$servers = Read-SpreadSheetOLE -SheetName "Citrix Farm" -filePath $deviceDetails | 
			where -FilterScript {($_.DeviceName -notlike "PRN*") -and ($_.DeviceName -notlike "*CTX00*")}}
		else {$servers = Read-SpreadSheetExcel -SheetName "Citrix Farm" -filePath $deviceDetails | 
			where -FilterScript {($_.DeviceName -notlike "PRN*") -and ($_.DeviceName -notlike "*CTX00*")}}
	}
	else {$servers = Get-ActiveCitrixServers | select server
#		if ($ExcelExists -eq $false) {$servers = Read-SpreadSheetOLE -SheetName "Citrix Farm" -filePath $deviceDetails | 
#			where {($_.DeviceName -like "DC*") -and ($_.DeviceName -notlike "*CTX00*")}}
#		else {$servers = Read-SpreadSheetExcel -SheetName "Citrix Farm" -filePath $deviceDetails | 
#			where {($_.DeviceName -like "DC*") -and ($_.DeviceName -notlike "*CTX00*")}}
	}
	foreach ($server in $servers) {
		if ($IncludePS4Sessions.IsPresent -eq $true) {$servername = $server.devicename} else {$servername = $server.server}
		Write-Host "Checking $servername for active sessions"
		Write-Host ''
		$newsessions = getWMI-UserSessions -server $servername -username $username
		Switch ($newsessions) {
			("ConnectionFailed") {
				$noConnection += @"
$servername

"@
			}
			("NoMatches") {$NoMatches += @($Server)}
			default {$sessions += @($_)}
		}
	}
	If (($NoMatches -notlike $null) -and ($sessions -like $null)) {$Sessions = "NoMatches"} 
	if (($noConnection -notlike $null) -and ($sessions -like $null)) {$sessions = "ConnectionFailed"}
	Switch ($sessions.count) {
		($null) {
			if ($Sessions.GetType().Name -like "ManagementObject") {$count = 1} 
			else {$count = 0}
		}
		default {$count = $_}
	}
	$endtime = Get-Date -Format HH:mm:ss
	$duration = New-TimeSpan -Start $starttime -End $endtime
	$LogString = @"
Start time: $starttime
End Time: $Endtime
Duration: $duration

Could not connect to the following machines:
$noConnection

$count Active Sessions found for $username

"@
	If ($count -gt 0) {
		$string = Make-friendlylist $sessions | ft SessionID,ServerName,SessionState,LastInputTime -AutoSize | Out-String
		$LogString += @"
$string

"@
	}
	$EntryType = "Information"
	if ($noConnection -notlike $Null) {
		$nothing = MsgBox -style 16 -Prompt @"
Unable to Connect to these servers:
$noConnection

Please check for user sessions manually before continuing.

Click OK when ready to Continue
"@
		$EntryType = "Warning"
	}
	$LogString = SDP_Log -jobnumber $JobNumber -credentials $credentials -LogString $LogString
	Write-EventLog -EntryType $EntryType -EventId 0 -Message $LogString -LogName $LogFile -Source 'Get-CitrixSessions'
	Return $sessions
}

Function get-UserSessions {Param ($computer = $env:COMPUTERNAME, $username = $null)
	$list = $null
	$processes = gwmi win32_process -computer $computer -Filter "Name = 'explorer.exe'" -ErrorAction SilentlyContinue
	if ($processes -notlike $null) {
		ForEach ($process in $processes) {
			$user=[string]($process.GetOwner()).User
		$logontime = [System.Management.ManagementDateTimeconverter]::ToDateTime($process.CreationDate)
		$sessionID = $process.sessionID
		$server = $process.CSName
		$list += @(New-object -TypeName PSObject -Property @{
				LogonTime=$logontime
				username=$user
				SessionID=$sessionID
				server=$server})
		}
	}

Return $list
}
Function Make-friendlylist {Param ($sessions)
	$ltype = DATA {
		ConvertFrom-StringData -StringData @"
0 = Active
4 = Disconnected
"@
	}
		
	foreach ($session in $sessions) {
		$ConnectTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($session.ConnectTime)
		$CurrentTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($session.CurrentTime)
		$DisconnectTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($session.DisconnectTime)
		$LastInputTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($session.LastInputTime)
		$LogonTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($session.LogonTime)
		$sessionState = $ltype[$session.SessionState.ToString()]
		$SessionUser = $($($session.SessionUser.Split('=')[1]).trim(",AccAuthority")).trim('"')

	
		$friendlyItems += @(New-Object -TypeName PSObject -Property @{
			ConnectTime=$ConnectTime
			CurrentTime=$CurrentTime
			DisconnectTime=$DisconnectTime
			LastInputTime=$LastInputTime
			LogonTime=$LogonTime
			ServerName=$session.ServerName
			SessionID=$session.SessionID
			SessionState=$sessionState
			SessionUser=$SessionUser
			}
		)
	}
	Return $FriendlyItems
}

Function Get-ActiveCitrixServers {Param ($PublishedApplication = @("*Parmalat XenApp*","*XenApp Desktop - DC1*","*XenApp Desktop - DC2*","*XenApp Desktop - LIMS*"))
	$namespace = "root\citrix"
	$class = "Metaframe_ApplicationsPublishedonServer"
	$datacollector = $null; $list = $null; $cleanlist = $null
	If ($PublishedApplication -eq $null) {Throw "Must supply a published application to query on!"}
	if ($(Test-Connection -Count 1 -ComputerName "dc1ctx00p01" -Quiet) -eq $true) {$datacollector = "dc1ctx00p01"}
	else {if ($(Test-Connection -Count 1 -ComputerName "dc2ctx00p01" -Quiet) -eq $true) {$datacollector = "dc2ctx00p01"}}
	if ($datacollector -eq $null) {Throw "Unable to connect to a Data Collector. Process Halted"}
	foreach ($app in $PublishedApplication) {$list += @(Get-WmiObject -Namespace $namespace -Class $class -ComputerName $datacollector |
													Where -FilterScript {$_.WinApp -like $app})}
	foreach ($entry in $list) {
		$apps = $null
		$serverapps = $list | where -FilterScript {$_.CtxServer -like $entry.CtxServer}
		foreach ($server in $serverapps) {$apps += @($server.WinApp.split('"')[1])}
		$cleanlist += @(New-Object -TypeName PSObject -Property @{
			Server = $entry.CtxServer.split('"')[1]
			Apps = $apps
			}
		)
	}
	
	$list = $cleanlist | sort -Property Server -Unique
	Return $list
}