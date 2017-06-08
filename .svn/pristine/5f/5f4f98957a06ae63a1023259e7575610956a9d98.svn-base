param 	($SourceFile = "\\parma.internal\dfsroot\GBS\HelpDesk\Scripts\device details.xlsx", `
		$SheetName, `
		[String[]]$EmailTo = "service.delivery.team@Parmalat.com.au", `
		[String[]]$EmailErrorsTo = "helpdesk@parmalat.com.au", `
		$Pings = 4, `
		[Switch]$Help)

Clear-Host
$Error.Clear()
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$Splitdir = $ScriptsDir.Split('\')
If ($Splitdir.Count -gt 4) {
	$ScriptsDir = $null
	for ($i = 0; $i -lt 4; $i++) {
		$ScriptsDir += $Splitdir[$i] + '\'	
		}
	}
$SysDir = ($ScriptsDir.Replace($($Splitdir[3] + '\'),'') + 'common')
. ($SysDir + '\Powershell.ps1')
. ($SysDir + '\VBFunctions.ps1')
. ($SysDir + '\ParmalatData.ps1')

function func_Help {$body = '<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	Device Ping Checks -- Help File</P>
	<SPAN Style="Font-family:Arial;font-size:10pt;">
	<P>Use this tool to ping any devices on the network. 
	It reads a list of device names and IP addresses from any correctly formatted 
	Spreadsheet, pings the devices and returns a list of any failed devices</P>
	<P Style="font-weight:Bold;font-size:13pt">Spread Sheet Format</P>
	<P>The Spread sheet that you are reading from must be formatted in a certain way.</P>
	<P Style="padding-left:50pt">Column "A" needs to have the device name in it.<BR>
	Column "B" needs to be the device IP address.<BR>
	Both Columns need to have a heading in Row 1.<BR>
	Row 1 is not included in the device details.<BR>
	All sheet names need to be unique within the work book.<BR>
	The sheet name is also used in the script to set the subject line of the email message.</P>
	<P Style="font-weight:Bold;font-size:13pt">Running From the Wiki</P>
	<P>At this point in time this script can not be run on any other machine except for VMUpdates2.
	It can be run from a link on the wiki when logged into ParmaApps. This link sets all parameters except for the sheet name
	(which you are prompted for) and will email the results to the user name that clicked on the link.
	Don''t click the link on the wiki if the account you are operating from dosen''t have an exchange account
	because it will fail to email you.</P>
	<P>The Wiki Link is called "<A HREF="file://\\Parma.Internal\dfsroot\GBS\HelpDesk\Wiki\CheckNetworkDevicesPing.cmd">Ping Network Devices (Run from ParmaApps)</A>"
	And is located in the "<SPAN Style="font-weight:bold">Tools & Utilities</SPAN>" Section of the Wiki Home Page. The Wiki Link only uses the default spread sheet and emails results to your email address (Not the help desk group).
	To make full use of the script it needs to be run from VMUpdates2</P>
	<P Style="font-weight:Bold;font-size:13pt">Running From VMUpdates2</P>
	<P>You only need to run from VMUpdates2 if you want to:</P>
	<P Style="padding-left:50pt">Change the Source File.<BR>
	Change the "-EmailTo" Parameter to an address other than your own<BR>
	Add the "-EmailErrorsTo" Parameter<BR>
	Change the Number of Pings</P>
	<P>To Run from VMUpdates2 you need to RDP to VMUpdates2 using an admin account<BR>
	Run the Command Prompt as administrator (Right Click command prompt and select "Run As Administrator")<BR>
	Run the script by calling powershell with the "-file" parameter, <SPAN Style="font-weight:bold">
	Powershell -File "' + $MyInvocation.scriptname + '"</SPAN><BR>
	Then list parameters (you must specify the "<SPAN Style="font-weight:bold">-SheetName</SPAN>" Parameter)<BR>
	Errors are also emailed to the person running the script.</P>
	<P Style="font-weight:Bold;font-size:13pt">Command Parameters</P>
	<P Style="text-decoration:underline">Required Parameters</P>
	<P><SPAN Style="font-weight:bold">-SheetName</SPAN>: This is the Name of the Work Sheet that you want to get details from. This parameter has no default and must always be specified.</P>
	<P Style="text-decoration:underline">Optional Parameters</P>
	<P><SPAN Style="font-weight:bold">-SourceFile</SPAN>: This is the Path to the Spreadsheet to read device details from. If you want to use the default Spread sheet then do not specify this parameter.</P>
	<P style="padding-left:50pt">The Default spreadsheet is located here:
		<A HREF="file://\\parma.internal\dfsroot\GBS\HelpDesk\Network listing\Cisco\Di Data Uptime Advantage\device details.xls">
		\\parma.internal\dfsroot\GBS\HelpDesk\Network listing\Cisco\Di Data Uptime Advantage\device details.xls</A></P>
	<P><SPAN Style="font-weight:bold">-EmailTo</SPAN>: Sets the email address to send the ping check to.</P>
	<P Style="padding-left:50pt">The Default for this parameter is the help desk group (helpdesk@parmalat.com.au)<BR>
	This needs to be a full email address (parmalat.com.au or pauls.internal). 
	Will not accept just a user name as it can not query exchange for the email address.</P>
	<P><SPAN Style="font-weight:bold">-EmailErrorsTo</SPAN>: Add Extra email addresses to notify if errors occur in the check.</P>
	<P Style="padding-left:50pt">Just list the full addresses as they would be typed in outlook, seperated by semi-colons.
	If devices do not respond to the check then these email addresses are added to recipients list before the email is sent</P>
	<P><SPAN Style="font-weight:bold">-Pings</SPAN>: Sets the number of Pings to attempt on each device.</P>
	<P Style="padding-left:50pt">The minimum and default number of pings is 4. the higher this number the more accurate the check is but it will also take longer to execute, meaning that it takes longer to recieve the email.</P>
	<P><SPAN Style="font-weight:bold">-Help</SPAN>: Emails this help file.
	</SPAN>'
	Return $Body
	}

#Links to Wiki Articles for the devices that have them

#$strCitrixWiki = "http://vmintranet01/ITsupportknowledgebase/Knowledge%20Base/Citrix/Procedures/System%20Crash%20(Blue%20Screen).aspx"
$strRFWiki = "http://vmintranet01:8080/AddSolution.do?solID=158"
$strtelmaxwiki = "http://vmintranet01:8080/AddSolution.do?solID=217"
$kioskswiki = "http://vmintranet01:8080/AddSolution.do?solID=317"

#Default Email Fields Contents. These fields are set to different values throughout the script in certain cases
#If all devices respond to the check and there are no script errors then the values remain as they are here.

$strEmailFrom = "HelpDesk@parmalat.com.au"
$SMTPServer = "webmail.parma.internal"
$strEmailSubject = "$SheetName Ping Check"
$strEmailBody = '<SPAN Style="Font-family:Arial;font-size:10pt;"><P>The ping check was Successful for all devices.</P><P>No Action Required.</P></SPAN>'
$strErrSubject = "$SheetName Ping Check. -- Devices Not Responding!!"

#ISDN Check Subject Line if there are errors

$strEmailErrISDN = '<SPAN Style="Font-family:Arial;font-size:10pt;"><P>The following devices have responded to the ' + $SheetName + ' ping check. All ' + $SheetName + ' devices should be disconnected.</P>'

#This is the Difrerent strings that make up the email body. These string are combined with the device details
#Top of the email body
$strEmailErrHead = '<SPAN Style="Font-family:Arial;font-size:10pt;"><P>The following devices have not responded to the ' + $SheetName + ' ping check.</P>'
#Bottom of the Email Body
$strEmailErrGeneral = '</P><P>Please ensure that a <A HREF="mailto:helpdesk@parmalat.com.au">HelpDesk</A> Job has been logged for this outage.<br>'
$strEmailErrCitrix = '</P><P>Please let <A HREF="mailto:hornj">Jeff</A> know Immediately.<br>In Jeff''s Absence please bring this issue to the <A HREF="mailto:citrixsupport@parmalat.com.au">citrix support</A> team''s attention.'
$strEmailErrDesktop = '</P><P>Please let <A HREF="mailto:haynesj">Jason</A> know Immediately.<br>In Jason''s Absence please bring this issue to The <A HREF="mailto:pcsupport@parmalat.com.au">desktop provisioning</A> team''s attention.'
$strEmailErrRF = '</P><P>Please let <A HREF="mailto:wynoogstc">Clinton</A> know Immediately.<br>In Clinton''s Absence please bring this issue to the <A HREF="mailto:pcsupport@parmalat.com.au">PC support</A> team''s attention.'
#IF there is a wiki article then set the hyperlink
Switch($SheetName) 
	{
	"Citrix Farm" {$strWikiLink = ""; $strEmailErrFoot = $strEmailErrCitrix}
	"RF Equipment" {$strWikiLink = $strRFWiki; $strEmailErrFoot = $strEmailErrRF}
	"Telmax" {$strWikiLink = $strtelmaxwiki; $strEmailErrFoot = $strEmailErrGeneral}
	"Kiosks" {$StrWikiLink = $kioskswiki; $strEmailErrFoot = $strEmailErrDesktop}
	default {$strWikiLink = ""; $strEmailErrFoot = $strEmailErrGeneral}
	}
$strEmailErrWiki = '<P>Otherwise, please <A HREF="' + $strWikiLink + '">Click Here</A> for the wiki article associated with the ' + $SheetName + ' ping check.</P></SPAN>'

#Script Error Messages

$strErrFile = '<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	Invalid File Path entered.</P>
	<P>"<SPAN Style="font-weight:bold">' + $SourceFile + '</SPAN>" does not exist.</P>
	<P>Please enter a valid file name and path.</P>'
$strErrSheet = '<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	Invalid sheet name entered.</P>
	<P>A Sheet with the name of "<SPAN Style="font-weight:bold">' + $SheetName + '</SPAN>" does not exist in the following file:</P>
	<P><A HREF="' + $SourceFile + '"><SPAN Style="font-weight:bold"> ' + $SourceFile + '</SPAN></A>.</P>
	<P>Please enter a valid sheet name</P>'


#             Functions

function func_TestSourceFile {
$subject = 'Script Error - Ping Checks'
$body = '<SPAN Style="Font-family:Arial;font-size:10pt;">' + $strErrFile + '</SPAN>'
Switch($SourceFile){
	"" {Send-MailMessage -From $strEmailFrom -To $EmailTo.Replace('"','') -Body $body -Priority High -Subject $subject -SmtpServer $SMTPServer -BodyAsHtml
		Exit}
	default {
		If ((Test-Path $SourceFile) -eq $false) 
			{Send-MailMessage -From $strEmailFrom -To $EmailTo.Replace('"','') -Body $body -Priority High -Subject $subject -SmtpServer $SMTPServer -BodyAsHtml
			Exit}
		}
	}
}

Function func_PingDevice {Param ($arrWorkSheet)
$i = 0
ForEach ($rec IN $arrWorkSheet)
	{
	$p = 0
	DO
		{
		$strQuery = "select statuscode from Win32_PingStatus where address = '" + $arrWorkSheet[$i].DeviceIP + "'"
		$objStatus = Get-WmiObject -Query "$strQuery"
		Switch($SheetName)
			{
			"WANSecondary"{$strEmailErrHead = $strEmailErrISDN
					$strErrSubject = "$SheetName Ping Check. -- $SheetName Devices Have Responded!!"
					If ($objStatus.StatusCode -ne 0)
					{
					$rec.ReturnedPings++
					$p++
					}
					Else {$p++}}
			default {If ($objStatus.StatusCode -eq 0)
					{
					$rec.ReturnedPings++
					$p++
					}
					Else {$p++}
					}
			}
		}
	Until ($p -eq $Pings)
	$i++
	If ($rec.ReturnedPings -lt ($Pings/2))
		{
		$objNoReply = New-Object -TypeName PSObject -Property @{
			DeviceName = $rec.DeviceName;
			DeviceIP = $rec.DeviceIP}
		$arrNoReply += $objNoReply
		}
	}
Return $arrNoReply
}

# End of Functions *********

#Email Help Page to user

If ($Help.IsPresent) {
	$body = func_Help
	Send-MailMessage -From $strEmailFrom -To $EmailTo.Replace('"','') -Body $body -Subject 'Ping Checks - Help File' -SmtpServer $SMTPServer -BodyAsHtml
	exit
	}

func_TestSourceFile

$objWorkSheet = Read-spreadsheetOLE -filepath $SourceFile -Sheetname $SheetName
if ($objWorkSheet.gettype().BaseType -like "System.Object") {$RowCOunt = 1}
else {$RowCount = $objWorkSheet.count}

$Global:arrWorkSheet = @()
$Global:arrNoReply = @()
$i = 0
Do
	{
	$Global:objDevices = New-Object -TypeName PSObject -Property @{
		DeviceName = $objWorkSheet[$i].DeviceName
		DeviceIP = $objWorkSheet[$i].DeviceIPAddress
		ReturnedPings = 0}
	$arrWorkSheet += $objDevices
	$i++
	}
Until ($i -eq $RowCount)
$arrNoReply = func_PingDevice $arrWorkSheet
If ($arrNoReply -ne $null)
	{
	If ($emailerrorsto -notlike $null) {$EmailTo += $EmailErrorsTo}
	$strHTMLNoReply = $arrNoReply | ConvertTo-Html -Property DeviceName, DeviceIP
	$strEmailBody = $strEmailErrHead + $strHTMLNoReply + $strEmailErrFoot
	If ($strWikiLink -ne "")
		{
		$strEmailBody = $strEmailBody + $strEmailErrWiki				
		}
	foreach ($Address in $Emailto) {Send-MailMessage -BodyAsHtml $strEmailBody -From $strEmailFrom -Subject $strEmailSubject -to $address -Priority High -SmtpServer $SMTPServer}
	}
Else {Send-MailMessage -BodyAsHtml $strEmailBody -From $strEmailFrom -Subject $strEmailSubject -to $EmailTo -SmtpServer $SMTPServer}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPxZWzYwdj4d5DbeIHXscvH5C
# oTegggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FPuYM8xvZZkfbjH/IzF7D/TWK+lyMA0GCSqGSIb3DQEBAQUABIGAZH4jlzFCfalL
# bol7RrWZ81RJI9Q7qntgohtUuFvgIYJirCbEP08e0fNqHjDLfwZIeUi42vPvwS5J
# T0OHM6ABuGdI8+C237myoMv4M7lQygR7i5ZwCAZe/M3sGDRnT1Qtm5Utn3HOToQl
# ErD9RC+9L76gg/sXAOuNneVwtmdL8NY=
# SIG # End signature block
