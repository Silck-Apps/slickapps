Param ($SourceFile,
	$DC = $env:LOGONSERVER.trim('\'),
	$LogFile = 'Help Desk - Add Users',
	$MemberOf = '"Parmalat Users","All Users Australia"',
	$OU = 'HelpDeskImport',
	$Password = 'Password1',
	[Switch]$SharedMailbox,
	[Switch]$RegisterEventLog,
	[Switch]$Help,
	[switch]$Generic,
	[switch]$GenericNoProfile,
	[Switch]$StandardMeetingRoom,
	[switch]$VideoConferenceMeetingRoom,
	[switch]$DelegateControlledMeetingRoom)

$VCAdditionalReponse = "If your meeting request has been declined, please review the " + `
	"Scheduling Assistant in Outlook to find an alternative time for your meeting. If " + `
	"you are unable to re-schedule and you would like to make contact with the organiser " + `
	"of the adjacent meeting then please contact Brisbane Reception either by email " + `
	"brisbane.reception@parmalat.com.au or phone extension 71100 or external dial 07 38400 100 " + `
	"and they can let you know who has the adjacent booking."

$DelegateAdditionalResponse = "CAUTION: You have tentatively booked the " + $Displayname + `
	". Due to the strategic use of this room, your booking may be declined at any " + `
	"time and you may need to find an alternative room."

#----------------------------------------------------------------------------------------------
#----------------------  Display Help Dialoge   --------------------------------------#
Function ShowHelp {
	Write-Host ''
	Write-Host '********************  Add New User accounts   ****************************'
	Write-Host ''
	Write-Host 'Use this script to add one or more new users to Active Directory.'
	Write-Host 'OR also can be used for Shared Mailbox and Meeting Room additions'
	Write-Host ''
	Write-Host 'Run the script without any parameters to add a single standard user'
	Write-Host ''
	Write-Host 'Command parameters:'
	Write-Host ''
	Write-Host '    -SourceFile: Specifies the source file to get data from.'
	Write-Host ''
	Write-Host '                 NB: If you don''t supply this parameter then you will be asked to'
	write-host '                     manually input the required data. File must be a CSV file. Specify'
	write-host '                     a valid CSV file to perform a bulk addition of users'
	Write-Host ''
	Write-Host '    -DC: Specifies the Domain Controller to interact with.'
	write-host '         Default value is your current logon server: "'$DC'"'
	Write-Host ''
	Write-Host '    -LogFile: Specifies the Log file name to add logging entries to.'
	write-host '              Default log file is "'$LogFile'" on vmgbsadmin.'
	Write-Host ''
	Write-Host '              NB: You MUST run the "-RegisterEventLog" option first if the log file you want'
	Write-Host '                  to use dosen''t exist.'
	Write-Host ''
	Write-Host '    -Memberof: A comma seperated list of groups that the user(s) should be a member of.'
	Write-Host '               Default value is '$MemberOf
	Write-Host ''
	Write-Host '    -OU: The OU to create the users in.'
	Write-Host '         Default value is "'$OU'"'
	Write-Host ''
	Write-Host '    -Password: the password to set for all users being added'
	Write-Host '               The default password is "'$Password'"'
	write-host ''
	Write-Host 'Command Switches:'
	write-host ''
	Write-Host '    -Generic: Specify this switch to create a generic account'
	Write-Host ''
	Write-Host '	-GenericNoProfile: Generic account with no M drive or roaming profile'
	write-host ''
	Write-Host '    -SharedMailbox: Specify this switch to create a shared mailbox instead of a user account.'
	write-host ''
	Write-Host '	-StandardMeetingRoom: Specify this switch to create an automated meeting room resource'
	write-host ''
	Write-Host '	-VideoConferenceMeetingRoom: Specify this switch to create a meeting room for the VC System'
	Write-Host ''
	write-host '	-DelegateControlledMeetingRoom: Specify this switch to setup a meeting room that is controlled by delegates'
	write-host ''
	write-host '    -RegisterEventLog: Specify this switch to setup a new event log for the script.'
	write-host ''
	Write-Host '    -Help: Displays this help file.'
	Write-Host ''
	Write-Host '*****************************************************************************************'
	Write-Host ''
	Write-Host 'Would you like more information? (y/n)'
	$key=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Write-Host ''
	switch ($key.character) {
		"y" {MoreInfo}
		default {Exit}
	}
}

function MoreInfo {
	Write-Host '********************  Add New User accounts - More Information   ****************************'
	Write-Host ''
	Write-Host ' The script performs the following tasks:'
	Write-Host ''
	Write-Host '	* Validate''s proposed User against SAP2AD, Performalat and Custom Recipient Objects'
	Write-Host '    * Creates Exchange mailbox and active directory user accounts'
	Write-Host '    * Edits all active directory fields'
	Write-Host '    * Creates the user''s M drive folder'
	write-host '    * Creates the M drive share name and applies folder permissions'
	Write-Host '	* Removes all Folder Access groups that require approval from someone'
	Write-Host '	* Removes all groups controlling extra functionality (OWA, Mobile Iron, Blackberry, etc)'
	Write-Host '    * Copies requested user''s group membership to the new user'
	write-host ''
	Write-Host '***************************************************************************************************'
	Write-Host ''
	Exit
}

#----------------------   Error Handler   -------------------------------------------------
Trap {$Msg = $_.Exception.Message; $Line = $_.InvocationInfo.ScriptLineNumber; $cmd = $_.InvocationInfo.InvocationName
$LogString = @"
$Msg
Script Line Number: "$Line"
Command: "$Cmd"
"@
Write-EventLog -EntryType Error -EventId 3 -Message $LogString -LogName $LogFile -Source 'Add-Users.ps1'
	Switch ($_.CategoryInfo.Category){
		'OperationStopped' {Write-EventLog -EntryType Error -EventId 1 -Message 'Operation Halted' -LogName $LogFile -Source 'Add-Users.ps1'
			$ErrorActionPreference = $Errorpref
			Exit
		}
		default {Continue}
	}
}

Function Register-EventLog {
	New-EventLog -LogName $LogFile -Source 'NewUsers.ps1'
	New-EventLog -LogName $LogFile -Source 'Add-Users.ps1'
	New-EventLog -LogName $LogFile -Source 'New-Mailbox'
	New-EventLog -LogName $LogFile -Source 'Set-QADUser'
	New-EventLog -LogName $LogFile -Source 'Add-MailboxPermission'
	New-EventLog -LogName $LogFile -Source 'Add-ADGroup'
	New-EventLog -LogName $LogFile -Source 'Add-ADGroupMember'
	New-EventLog -LogName $LogFile -Source 'Add-M Drive Directory'
	New-EventLog -LogName $LogFile -Source 'Remove-AuthorisedGroups'
	New-EventLog -LogName $LogFile -Source 'Validate-ADUser'
	Exit
}

Function ManualInput { Param ($MbxType)
	Switch ($MbxType) {
		'CitrixUser-Standard' {$Data = New-Object -TypeName PSObject -Property @{
			JobNumber = $(InputBox -title 'Enter SDP Job Number' -Prompt 'Enter the Service desk plus job Number (Required)')
			EmpNo = $(InputBox -title 'Enter Employee Number' -Prompt 'Enter the User''s Employee Number (Required)')
			FirstName = $(InputBox -title 'Enter First Name' -Prompt 'Enter the User''s First Name (Required)')
			LastName = $(InputBox -title 'Enter Last Name' -Prompt 'Enter the User''s Last Name (Required)')
			Site = $(InputBox -title 'Enter the site name' -Prompt 'Enter the site name (Required)')
			Phone = $(Inputbox -title 'Enter Phone number' -Prompt 'Enter the User''s office phone number (Optional)')
			JobTitle = $(InputBox -title 'Enter Job Title' -Prompt 'Enter the user''s Job Title (Optional)')
			CC = $(InputBox -title 'Enter the Cost Centre' -Prompt 'Enter the User''s Cost Centre (Required)')
			Mobile = $(InputBox -title 'Enter Mobile Number' -Prompt 'Enter the user''s Mobile Number (Optional)')
			Fax = $(InputBox -title 'Enter Fax Number' -Prompt 'Enter the User''s Fax Number (Optional)')
			Dept = $(InputBox -title 'Enter Department' -Prompt 'Enter the User''s Department (Optional)')
			CopyUser = $(InputBox -title 'Enter username to copy' -Prompt 'Enter the Username of the user to copy (Optional)')
#			Environment = $(InputBox -title 'Enter Environment Settings' -Prompt 'Enter settings for the "Start Program" option in Active Directory (Optional)')
			}
		}
		default {$Data = New-Object -TypeName PSObject -Property @{
			JobNumber = $(InputBox -title 'Enter SDP Job Number' -Prompt 'Enter the Service desk plus job Number (Required)')
			Alias = $(InputBox -title 'Enter Alias' -Prompt 'Enter the Mailbox''s Alias (Required)')
			DisplayName = $(InputBox -title 'Enter Display Name' -Prompt 'Enter the Mailbox''s Display Name (Required)')
			Description = $(InputBox -title 'Enter Description' -Prompt 'Enter Description for Active Directory (Required)')
			Site = $(InputBox -title 'Enter the site name' -Prompt 'Enter the site name (Required)')
			Phone = $(Inputbox -title 'Enter Phone number' -Prompt 'Enter the User''s office phone number (Optional)')
			Email = $(InputBox -title 'Enter Email' -Prompt 'Enter email prefix (The bit before "@parmalat.com.au"... - Required)')
			CC = $(InputBox -title 'Enter the Cost Centre' -Prompt 'Enter the User''s Cost Centre (Optional)')
			Dept = $(InputBox -title 'Enter Department' -Prompt 'Enter the User''s Department (Optional)')
			AccessList = $(InputBox -title 'Enter User Names' -Prompt 'Enter a comma delimited list of users that require access (Need at least one entry)')
			}
		}
	}
Return $Data
}

Function AutoInput {Param ($MbxType, $SourceFile)
	If ((Test-Path $SourceFile) -eq $false) {Throw 'SourceFile: "' + $SourceFile + '" Does Note Exist. Operation Halted....'}
		Else {[xml]$XMLData = Get-Content -Path $SourceFile}
		Switch ($MbxType) {
#		'User' {$Data = New-Object -TypeName PSObject -Property @{
#			EmpNo = $(InputBox -title 'Enter Employee Number' -Prompt 'Enter the User''s Employee Number (Optional)')
#			FirstName = $(InputBox -title 'Enter First Name' -Prompt 'Enter the User''s First Name (Required)')
#			LastName = $(InputBox -title 'Enter Last Name' -Prompt 'Enter the User''s Last Name (Required)')
#			Site = $(InputBox -title 'Enter the site name' -Prompt 'Enter the site name (Required)')
#			Phone = $(Inputbox -title 'Enter Phone number' -Prompt 'Enter the User''s office phone number (Optional)')
#			JobTitle = $(InputBox -title 'Enter Job Title' -Prompt 'Enter the user''s Job Title (Optional)')
#			CC = $(InputBox -title 'Enter the Cost Centre' -Prompt 'Enter the User''s Cost Centre (Optional)')
#			Mobile = $(InputBox -title 'Enter Mobile Number' -Prompt 'Enter the user''s Mobile Number (Optional)')
#			Fax = $(InputBox -title 'Enter Fax Number' -Prompt 'Enter the User''s Fax Number (Optional)')
#			Dept = $(InputBox -title 'Enter Department' -Prompt 'Enter the User''s Department (Optional)')
#			CopyUser = $(InputBox -title 'Enter username to copy' -Prompt 'Enter the Username of the user to copy (Optional)')
#			}
#		}
		default {$Data = New-Object -TypeName PSObject -Property @{
			Alias = $XMLData.myFields.SMTPAddress
			DisplayName = $XMLData.myFields.DisplayName
			Description = $XMLData.myFields.Description
			Site = $XMLData.myFields.SiteName
			Phone = $XMLData.myFields.ContactPhone
			Email = $XMLData.myFields.SMTPAddress
			CC = $XMLData.myFields.CostCenter
			Dept = $XMLData.myFields.BusinessUnit
			FormType = $XMLData.myfields.FormType
			AccessList = @()
			}
			If ($XMLData.myfields.AccessList -notlike $null) {
				If ($Data.AccessList.Count -eq 1) {$Data.AccessList = $Data.AccessList[0].trim("QUF\")}
				Else {foreach ($User in $XMLData.myFields.AccessList.Person) { $Data.AccessList += $User.AccountId.trim("QUF\")}}
			}
		}
	}
	
	Return $Data
}

Clear-Host
$Error.Clear()
$ErrPref = $ErrorActionPreference`
# $ErrorActionPreference = 'SilentlyContinue'
Import-Module ActiveDirectory
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\PowerShell.ps1')
. ($SysDir + '\vbFunctions.ps1')
. ($SysDir + '\WMIFunctions.ps1')
. ($SysDir + '\SecurityFunctions.ps1')
. ($SysDir + '\NewUsers.ps1')
. ($SysDir + '\ADFunctions.ps1')
. ($SysDir + '\ParmalatData.ps1')
. ($SysDir + '\SDP.ps1')

# Set Mailbox Type

If ($RegisterEventLog.IsPresent -eq $true) {Register-EventLog}
If ($Help.IsPresent -eq $true) {ShowHelp}
$MbxType = 'CitrixUser-Standard'
If ($Generic.IsPresent -eq $true) {$MbxType = 'CitrixUser-Generic'}
If ($GenericNoProfile.IsPresent -eq $true) {$MbxType = 'CitrixUser-NoProfile'}
If ($SharedMailbox.IsPresent -eq $true) {$MbxType = 'Mailbox-Shared'}
If ($StandardMeetingRoom.IsPresent -eq $true) {$MbxType = 'RoomResource-Standard'}
If ($VideoConferenceMeetingRoom.IsPresent -eq $true) {$MbxType = 'RoomResource-VC'}
If ($DelegateControlledMeetingRoom.IsPresent -eq $true) {
	$MbxType = 'RoomResource-Delegate'
	$delegates = $(InputBox -title 'Enter Delegates' -Prompt 'Please enter a Comma delimited list (EG: "Value1","value2","value3") of users to be added. ' + `
			'You can use usernames or display names (or a mixture of both) for this list.')
}

$InsertFrom = 'Manual'
If ($SourceFile -ne $null){
	Switch ((Get-Item $SourceFile).Extension) {
		'.XML' {$InsertFrom = 'UserForm'}
		'.CSV' {$InsertFrom = 'BulkImport'}
	}
}

Write-Host $MbxType' Mailbox'
$credentials = $Host.ui.PromptForCredential("Enter SDP Credentials", "Please enter your Service Desk Plus credentials", $env:USERNAME.replace("_adm",""),"")
Switch ($InsertFrom) {
	'UserForm' {$Data = AutoInput -MbxType $MbxType -SourceFile $SourceFile}
	'BulkImport' {If ((Test-Path $SourceFile) -eq $false) {Throw 'SourceFile: "' + $SourceFile + '" Does Note Exist. Operation Halted....'}
		Else {$Data = Import-Csv -Path $SourceFile}}
	'Manual' {$Data = ManualInput $MbxType}
}

If ($InsertFrom -like 'UserForm') {
	Switch ($Data.FormType) {
		'SharedMailbox' {$MbxType = 'Shared'}
		'MeetingRoom' {$MbxType = 'Meeting Room'}
	}
}

$Alias = $Data.Alias; $DisplayName = $Data.DisplayName; $Description = $Data.Description; $Site = $Data.Site; $Phone = $Data.Phone; $Email = $Data.Email 
	$CC = $Data.CC; $Dept = $Data.Dept; $AccessList = $Data.AccessList
$LogString = @"
Added by: "$Env:USERNAME"
Mailbox Type: "$MbxType"
Source Data: "$InsertFrom"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Add-Users.ps1'


Switch ($MbxType) {
	'CitrixUser-NoProfile' {if ($Data.GetType().basetype.Name -like "object") {
		CitrixUser-NoProfile -CC $Data.CC `
			-DC $DC `
			-Department $Data.Dept `
			-EmpNo $Data.EmpNo `
			-Fax $Data.Fax `
			-FirstName $Data.FirstName `
			-JobTitle $Data.JobTitle `
			-LastName $Data.LastName `
			-LogFile $LogFile `
			-MemberOf $MemberOf `
			-Mobile $Data.Mobile `
			-OU $OU `
			-Password $Password `
			-Phone $Data.Phone `
			-Site $Data.Site `
			-CopyUser $Data.CopyUser `
			-jobnumber $Data.JobNumber `
			-credentials $credentials
#			-Environment $Environment
		}
	else {ForEach ($User in $Data) {
		CitrixUser-NoProfile -CC $User.CC `
			-DC $DC `
			-Department $User.Dept `
			-EmpNo $User.EmpNo `
			-Fax $User.Fax `
			-FirstName $User.FirstName `
			-JobTitle $User.JobTitle `
			-LastName $User.LastName `
			-LogFile $LogFile `
			-MemberOf $MemberOf `
			-Mobile $User.Mobile `
			-OU $OU `
			-Password $Password `
			-Phone $User.Phone `
			-Site $User.Site `
			-CopyUser $User.CopyUser `
			-jobnumber $User.JobNumber `
			-credentials $credentials
#			-Environment $Environment		
			}
		}
	}
	'CitrixUser-Standard' {if ($Data.GetType().basetype.Name -like "object") {
		CitrixUser-Standard -CC $Data.CC `
			-DC $DC `
			-Department $Data.Dept `
			-EmpNo $Data.EmpNo `
			-Fax $Data.Fax `
			-FirstName $Data.FirstName `
			-JobTitle $Data.JobTitle `
			-LastName $Data.LastName `
			-LogFile $LogFile `
			-MemberOf $MemberOf `
			-Mobile $Data.Mobile `
			-OU $OU `
			-Password $Password `
			-Phone $Data.Phone `
			-Site $Data.Site `
			-CopyUser $Data.CopyUser `
			-jobnumber $Data.JobNumber `
			-credentials $credentials
#			-Environment $Environment
		}
		else {ForEach ($User in $Data) {
				CitrixUser-Standard -CC $User.CC `
					-DC $DC `
					-Department $User.Dept `
					-EmpNo $User.EmpNo `
					-Fax $User.Fax `
					-FirstName $User.FirstName `
					-JobTitle $User.JobTitle `
					-LastName $User.LastName `
					-LogFile $LogFile `
					-MemberOf $MemberOf `
					-Mobile $User.Mobile `
					-OU $OU `
					-Password $Password `
					-Phone $User.Phone `
					-Site $User.Site `
					-CopyUser $User.copyuser `
					-jobnumber $User.SDPjobnumber `
					-credentials $credentials 
#					-Environment $Environment
				}
			}
		}
	'CitrixUser-Generic' {if ($Data.GetType().basetype.Name -like "object") {
		CitrixUser-Generic -CC $Data.CC `
			-DC $DC `
			-Department $Data.Dept `
			-EmpNo $Data.EmpNo `
			-Fax $Data.Fax `
			-FirstName $Data.FirstName `
			-JobTitle $Data.JobTitle `
			-LastName $Data.LastName `
			-LogFile $LogFile `
			-MemberOf $MemberOf `
			-Mobile $Data.Mobile `
			-OU $OU `
			-Password $Password `
			-Phone $Data.Phone `
			-Site $Data.Site `
			-CopyUser $Data.CopyUser `
			-jobnumber $Data.JobNumber `
			-credentials $credentials
#			-Environment $Environment
		}
	else {ForEach ($User in $Data) {
		CitrixUser-Generic -CC $User.CC `
			-DC $DC `
			-Department $User.Dept `
			-EmpNo $User.EmpNo `
			-Fax $User.Fax `
			-FirstName $User.FirstName `
			-JobTitle $User.JobTitle `
			-LastName $User.LastName `
			-LogFile $LogFile `
			-MemberOf $MemberOf `
			-Mobile $User.Mobile `
			-OU $OU `
			-Password $Password `
			-Phone $User.Phone `
			-Site $User.Site `
			-CopyUser $User.CopyUser `
			-jobnumber $User.JobNumber `
			-credentials $credentials
#			-Environment $Environment		
			}
		}
	}
	'Mailbox-Shared' {if ($Data.GetType().basetype.Name -like "object") {
			New-SharedMailBox -DisplayName $Data.DisplayName `
				-Alias $Data.Alias `
				-Phone $Data.Phone `
				-Site $data.Site `
				-CC $Data.CC `
				-Description $Data.Description `
				-Email $Data.Email `
				-Department $Data.Department `
				-LogFile $LogFile `
				-AccessList $Data.AccessList `
				-jobnumber $Data.JobNumber `
				-credentials $credentials
		}
		else {ForEach ($User in $Data) {
			New-SharedMailBox -DisplayName $User.DisplayName `
				-Alias $User.Alias `
				-Phone $User.Phone `
				-Site $User.Site `
				-CC $User.CC `
				-Description $User.Description `
				-Email $User.Email `
				-Department $User.Department `
				-LogFile $LogFile `
				-AccessList $User.AccessList `
				-jobnumber $User.JobNumber `
				-credentials $credentials
				}
			}
		}
	'RoomResource-Standard' {if ($Data.GetType().basetype.Name -like "object") {
			RoomResource-standard -DisplayName $Data.DisplayName `
				-Alias $Data.Alias `
				-Phone $Data.Phone `
				-Site $data.Site `
				-CC $Data.CC `
				-Description $Data.Description `
				-Email $Data.Email `
				-Department $Data.Department `
				-LogFile $LogFile `
				-AccessList $Data.AccessList `
				-jobnumber $Data.JobNumber `
				-credentials $credentials
			}
		else {ForEach ($User in $Data) {
			RoomResource-standard -DisplayName $User.DisplayName `
				-Alias $User.Alias `
				-Phone $User.Phone `
				-Site $User.Site `
				-CC $User.CC `
				-Description $User.Description `
				-Email $User.Email `
				-Department $User.Department `
				-LogFile $LogFile `
				-AccessList $User.AccessList `
				-jobnumber $User.JobNumber `
				-credentials $credentials
			}
		}
	}
	'RoomResource-VC' {if ($Data.GetType().basetype.Name -like "object") {
			RoomResource-VC -DisplayName $Data.DisplayName `
				-Alias $Data.Alias `
				-Phone $Data.Phone `
				-Site $data.Site `
				-CC $Data.CC `
				-Description $Data.Description `
				-Email $Data.Email `
				-Department $Data.Department `
				-LogFile $LogFile `
				-AccessList $Data.AccessList `
				-jobnumber $Data.JobNumber `
				-credentials $credentials `
				-AdditionalResponse $VCAdditionalReponse
			}
		else {ForEach ($mailbox in $Data) {
			RoomResource-VC -DisplayName $mailbox.DisplayName `
				-Alias $mailbox.Alias `
				-Phone $mailbox.Phone `
				-Site $mailbox.Site `
				-CC $mailbox.CC `
				-Description $mailbox.Description `
				-Email $mailbox.Email `
				-Department $mailbox.Department `
				-LogFile $LogFile `
				-AccessList $mailbox.AccessList `
				-jobnumber $mailbox.JobNumber `
				-credentials $credentials `
				-AdditionalResponse $VCAdditionalReponse
			}
		}
	}
	'RoomResource-Delegate' {if ($Data.GetType().basetype.Name -like "object") {
		RoomResource-Delegate -DisplayName $Data.DisplayName `
				-Alias $Data.Alias `
				-Phone $Data.Phone `
				-Site $data.Site `
				-CC $Data.CC `
				-Description $Data.Description `
				-Email $Data.Email `
				-Department $Data.Department `
				-LogFile $LogFile `
				-AccessList $Data.AccessList `
				-jobnumber $Data.JobNumber `
				-credentials $credentials `
				-Delegates $delegates `
				-AdditionalResponse $DelegateAdditionalReponse
		}
		else {ForEach ($mailbox in $Data) {
		RoomResource-Delegate -DisplayName $mailbox.DisplayName `
				-Alias $mailbox.Alias `
				-Phone $mailbox.Phone `
				-Site $mailbox.Site `
				-CC $mailbox.CC `
				-Description $mailbox.Description `
				-Email $mailbox.Email `
				-Department $mailbox.Department `
				-LogFile $LogFile `
				-AccessList $mailbox.AccessList `
				-jobnumber $mailbox.JobNumber `
				-credentials $credentials `
				-Delegates $delegates `
				-AdditionalResponse $DelegateAdditionalReponse
			}
		}
	}	
}
Write-EventLog -EntryType Information -EventId 0 -Message 'Process Completed Succesfully' -LogName $LogFile -Source 'Add-Users.ps1'
Write-Host 'Process Completed.'
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWuw4f0XgB1+ISlEqwC/jKTmW
# 5r2gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FEYP+FNA8BM7cfmJjPcSVkdfGt1ZMA0GCSqGSIb3DQEBAQUABIGAPkv50LNguFln
# wOjovvPo9ty4Vj7ufUG0xBWIaGdzVpBEa8bK8FHhr+O9c8R7UIja20xHHBBLNTQM
# /QEhk8E2sNssJVqpNnPssYMCvnYvGq2EF3XxPTV1gmokjhL1bOneLQNHjqI63Goc
# V4Z67gVJc14f7UbjbJbE+HLbNqk5ghI=
# SIG # End signature block
