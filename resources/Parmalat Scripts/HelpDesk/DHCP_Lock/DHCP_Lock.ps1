Param($Action = 'Allow', [Switch]$Multiple, [Switch]$Help)
Clear-Host
$originalPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$error.clear()
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\vbFunctions.ps1')
. ($SysDir + '\WindowsForms.ps1')

#Trap {$ErrorActionPreference = $originalPreference
#	$Screen += $error[0] + "`n"
#	Exit}

Function ProcessData{
	Param($Mac,$Screen)
	If ($Mac.length -ne 12){$Screen += "Invalid Data: " + $Mac + "`n"
		$mac = $null}
	Else {
		$Mac = $Mac.ToUpper()
		$Mac = $Mac.Substring(0,2) + '-' + $Mac.Substring(2,2) + '-' + $Mac.Substring(4,2) + '-' + $Mac.Substring(6,2) + '-' + `
			$Mac.Substring(8,2) + '-' + $Mac.Substring(10,2)
}
Return $Mac,$Screen
}
Function ProcessMac {Param ($Mac,$URL,$Screen)
	$Mac,$Screen = ProcessData -Mac $Mac -screen $Screen
	If ($Mac -ne $null){
		$URL = $URLHead+$Mac+$HTMLAction
		$probe = $wc.DownloadData($URL) 
		If ($probe -eq $null) {$Screen += "Error!! Mac Address: '" + $Mac + "' Not Added... `n"}
		Else {$Screen += "Mac Address: " + $Mac + " -- Action: " + $Action + "`n"}
		$URL = $null
		$probe = $null}
	Return $Screen
	}

Switch ($action){
	'Allow' {$HTMLAction = '/A'}
	'Remove' {$HTMLAction = '/R'}
	'Deny' {$HTMLAction = '/D'}
	default {Throw 'Invalid Action Entered!! `n'}
}
$Screen = @()
$LogFile = 'DHCP Lock'
$LogSource = 'DHCP Lock.ps1'
$wc = new-object net.WebClient
$vbShell = New-Object -ComObject Wscript.Shell
$URLHead = 'http://1.1.8.77:68/'
$InitialDirectory = $env:TEMP
$OpenBoxTitle = 'Select the Source File...'
$Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
If ($Help.IsPresent -eq $True) {
	Write-Host '***********  DHCP Lock Help File  **********'
	Write-Host ''
	Write-Host 'This Script will load single or Multiple MAC addresses into DHCP Lock'
	Write-Host 'There are three Parameters. All Parameters are Optional'
	Write-Host ''
	Write-Host 'A Log File is Located Here: '$LogFile
	Write-Host ''
	Write-Host '-Action: Sets the Action you want to take. Default Value is "Allow"'
	Write-Host '	Valid vales are:'
	Write-Host '		"Allow" - Allow the Addresses entered'
	Write-Host '		"Remove" - Remove the addresses entered'
	Write-Host '		"Deny" - Denies the addresses entered'
	Write-Host ''
	Write-Host '-Multiple: Specify this switch and you will be prompted to open a file to import'
	Write-Host '	Only Excepts ".txt" files and should have only one MAC per line. Don''t hyphenate the Address. The Script does it for you'
	Write-Host ''
	Write-Host '-Help: Displays this Help Dialogue'
	Write-Host '******************************************'
	Exit
	}
$wc.Credentials = Get-Credential -OutVariable $null
If ($Multiple.Ispresent -eq $true) {
	$OpenFile = OpenFile -Filter $filter `
		-FilterIndex 0 `
		-DefaultExt '*.txt' `
		-Title $OpenBoxTitle `
		-InitialDirectory $InitialDirectory
	$MACs = Get-Content $OpenFile[1]
	ForEach ($Mac in $MACs){
		$Screen += ProcessMac $Mac $URL
	}	
}
Else {$Mac = InputBox -Prompt 'Please enter the MAC address (no hyphens)' -title "Enter Mac ID"
	$Screen = ProcessMac $Mac $URL}
$Date = Get-Date; $LogString = @"
$Date
Entered By: "$env:USERNAME"
$Screen
"@
Write-EventLog -LogName $LogFile -Source $LogSource -Message $LogString -EventId 0
$vbshell.popup($Screen,0,'DHCP Lock')
$ErrorActionPreference = $originalPreference
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUr0OPqvCUPDpXoRbHSoV/iM3g
# VmmgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FGkhUtoUPD5//0yPnhbc2SkTzJMYMA0GCSqGSIb3DQEBAQUABIGAAXPlS0W8vd1r
# d6ZkzDxyxzFmmUQw24ORgu3U9JXtus5Au+hI2MP0NCHkER7y3wk9uRB6b9iIOpJQ
# c5aCHBgGiKUNkfOElOsLml1th4tp+jbMXbbiIhGh4VSmXkXrmzReRyy3SuGu8qup
# usMpSGGVjZ5DbJGYI+TD/F34jRp+1BU=
# SIG # End signature block
