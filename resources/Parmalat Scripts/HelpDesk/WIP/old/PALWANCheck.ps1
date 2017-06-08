param 	($SourceFile = "\\parma.internal\dfsroot\GBS\NetworkSup\Cisco\Di Data Uptime Advantage\device details.xls", `
		$EmailTo = "HelpDesk@Parmalat.com.au", `
		$EmailErrorsTo, `
		$Pings = 4, `
		[Switch]$Help)

Clear-Host


function func_Help {'<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	This is the help File</P>'
	}

$strEmailFrom = "HelpDesk@parmalat.com.au"
$strEmailSubject = "Parmalat WAN Check"
#TOp of the email body
$strEmailHead = '<SPAN Style="Font-family:Arial;font-size:10pt;"><P>The Parmalat WAN network Check has been completed. Results shown below</P>'
#Bottom of the Email Body
$strEmailFoot = '</P><P>Please review any issues and let the Citrix Support team know'

$strErrFile = '<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	Invalid File Path entered.</P>
	<P>"<SPAN Style="font-weight:bold">' + $SourceFile + '</SPAN>" does not exist.</P>
	<P>Please enter a valid file name and path.</P>'
$strErrSheet = '<P Style="Font-family:Arial;font-size:16pt;text-decoration:Underline;font-weight:Bold;text-align:center;">
	Invalid sheet name entered.</P>
	<P>A Sheet with the name of "<SPAN Style="font-weight:bold">' + $Sheet + '</SPAN>" does not exist in the following file:</P>
	<P>"<SPAN Style="font-weight:bold"> ' + $SourceFile + '</SPAN>".</P>
	<P>Please enter a valid sheet name</P>'

#Excel Spreadsheet Column numbers and Sheet Names

$IntDevName = 1
$IntDevIP = 2
$arrSheetNames = @("Routers", "WANPrimary", "WANSecondary")

#             Functions

# ----------Release COM Object------------------------- 
function Release-Ref ($ref) 
	{ 
	([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	} 
# -----------------------------------------------------  
function Func_CreateEmail{Param ($strEmailFrom, $StrEmailTo, $strEmailSubject)
$objEmail = New-Object -ComObject CDO.Message
$objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
$objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.parma.internal"
$objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
$objEmail.Configuration.Fields.Update()
$objEmail.From = $strEmailFrom
$objEmail.To = $EmailTo
$objEmail.Subject = $strEmailSubject
Return $objEmail
}

function func_TestSourceFile {
Switch($SourceFile){
	"" {$objEmail.Subject = "Script Error - Ping Checks"
		$objEmail.HTMLbody = '<SPAN Style="Font-family:Arial;font-size:10pt;">' + $strErrFile + '</SPAN>'
		$objEmail.Send()
		Release-Ref($objEmail) > $null
		Exit}
	default {
		If ((Test-Path $SourceFile) -eq $false) 
			{$objEmail.Subject = "Script Error - Ping Checks"
			$objEmail.HTMLbody = '<SPAN Style="Font-family:Arial;font-size:10pt;">' + $strErrFile + '</SPAN>'
			$objEmail.Send()
			Release-Ref($objEmail) > $null
			Exit}
		}
	}
}

function func_OpenWorkSheet {Param ($SheetName)
$intSheetCount = $objExcel.Worksheets.Count
$i = 1
Do {
	$Global:objWorkSheet = $objWorkbook.Worksheets.Item($i)
	If ($SheetName -notmatch $objWorkSheet.Name)
		{
		$i++
		}
	If ($i -gt $intSheetCount)
		{$objEmail.Subject = "Script Error - Ping Checks"
		$objEmail.HTMLbody = $strErrSheet
		$objEmail.Send()
		$objExcel.Quit()
		Release-Ref($objEmail) > $null
		Release-Ref($objWorkSheet) > $null
		Release-Ref($objWorkBook) > $null
		Release-Ref($objExcel) > $null
		Exit
		}
	}
Until ($SheetName -match $objWorkSheet.name)

Return $objWorkSheet
}

Function func_PingDevice {Param ($arrSheet)
$i = 0
ForEach ($rec IN $arrSheet)
	{
	$p = 0
	DO
		{
		$strQuery = "select statuscode,responsetime from Win32_PingStatus where address = '" + $rec.DeviceIP + "'"
		$objStatus = Get-WmiObject -Query "$strQuery"
			If ($objStatus.StatusCode -eq 0)
				{
				$rec.ReturnedPings++
				$rec.Latency = ($objStatus.ResponseTime + $rec.Latency) / $rec.ReturnedPings
				$p++
				}
			Else {$p++}
		}	
	Until ($p -eq $Pings)
	$rec.Latency = [Math]::Round($rec.Latency, 2)
	$i++
	}
}

# ####################################              End of Functions *********

$Global:objExcel = New-Object -ComObject Excel.Application
$objExcel.displayalerts=$False
$Global:objWorkBook = $objExcel.Workbooks.Open($SourceFile)


$objEmail = func_createEmail $strEmailFrom $StrEmailTo $strEmailSubject

#Email Help Page to user

If ($Help.IsPresent) {
	$objEmail.Subject = "WAN Network Check - Help File"
	$objEmail.HTMLbody = func_Help
	$objEmail.Send()
	Release-Ref($objEmail) > $null
	exit
	}

func_TestSourceFile

ForEach ($Sheet in  $arrSheetNames){
	$i = 0
	Remove-Variable "arr$Sheet"
	New-Variable "arr$Sheet" @()
	$WorkSheet = func_OpenWorkSheet $Sheet
	$newRowCount = $WorkSheet.usedRange.Rows.Count - 1
	Do {
	$objDetails = New-Object -TypeName PSObject -Property @{
		DeviceName = $WorkSheet.Cells.Item(($i + 2),$IntDevName).value()
		DeviceIP = $WorkSheet.Cells.Item(($i + 2),$IntDevIP).value()
		ReturnedPings = 0
		Latency = $null
		}
	Invoke-Expression ('$arr' + $Sheet + ' += $objDetails')
	$i++
	}
	Until ($i -eq $newRowCount)
	If ($newRowCount -gt $RowCount) {
		$RowCount = $newRowCount
		$MaxRows = $WorkSheet.Name
		}
	}
$objExcel.Quit()
Release-Ref($objWorkSheet) > $null
Release-Ref($objWorkBook) > $null
Release-Ref($objExcel) > $null

ForEach ($Sheet in $arrSheetNames){func_PingDevice (Invoke-Expression('$arr' + $Sheet))}

$arrResults = @()
$SheetName = Invoke-Expression ('$arr' + $MaxRows)
ForEach ($rec in $SheetName){
$objDetails = New-Object -TypeName PSObject -Property @{
	DeviceName = $rec.Name
	RouterIP = $null
	RouterReturnedPings = $null
	RouterLatency = $null
	WANPrimaryIP = $null
	WANPrimaryReturnedPings = $null
	WANPrimaryLatency = $null
	WANSecondaryIP = $null
	WANSecondaryReturnedPings = $null
	WANSecondaryLatency = $null
	}
$arrResults += $objDetails
Switch ($sheet){
	"Routers" {$objDetails.RouterIP = $rec.DeviceIP}
	}	
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyWpEsR5fR76YO+CCZx1HIrno
# p1egggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FGZHLkbwBDT6uA7JijB1TjLB72R3MA0GCSqGSIb3DQEBAQUABIGABj8ihvRcYf4j
# 5ZLyTTB6Q3Xj822u9pVyhVizC5maTQsI6zk955FOXuJDHnutwi/X4PHig65arXii
# ZJkyxG0houg8lGFhMFc10rLuOZ3dPfLlYrMTlEC3lrNNiWUJLssFoR6ZZKAzCmVa
# CvyyqbeUEjyBkEiO1HguuVt1SKjSohM=
# SIG # End signature block
