Function MsgBoxStyle {Param ($buttons = 'OKOnly',
		$IconStyle,
		$DefaultButton = 'DefaultButton1',
		$modality = 'ApplicationModal',
		[Switch]$MsgBoxSetForeground, [Switch]$MsgBoxRight, [Switch]$MsgBoxRtlReading)
	Switch ($buttons) {
		'OKOnly'{$buttons = 0}
		'OKCancel' {$buttons = 1}
		'AbortRetryIgnore'{$buttons = 2}
		'YesNoCancel'{$buttons = 3}
		'YesNo'{$buttons = 4}
		'RetryCancel'{$buttons = 5}
	}
	Switch ($IconStyle) {
		'Critical' {$IconStyle = 16}
		'Question'{$IconStyle = 32}
		'Exclamation'{$IconStyle = 48}
		'Information'{$IconStyle = 64}
		default {$IconStyle = 0}
	}
	Switch ($DefaultButton) {
		'DefaultButton2'{$DefaultButton = 256}
		'DefaultButton3'{$DefaultButton = 512}
		default {$DefaultButton = 0}
	}
	Switch ($modality) {
		'SystemModal'{$modality = 4096}
		default {$modality = 0}
	}
	[Int32]$Switches = 0
	If ($MsgBoxSetForeground.IsPresent -eq $true){$Switches += 65536}
	If ($MsgBoxRight.IsPresent -eq $true) { $Switches += 524288}
	If ($MsgBoxRtlReading.IsPresent -eq $true) { $Switches += 1048576}
	[Int32]$Value = $buttons + $IconStyle + $DefaultButton + $modality + $Switches
	Return $Value	
}
# ----------Release COM Object------------------------- 
function Release-Ref ($ref) { 
	([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
} 
# -----------------------------------------------------  
Function OpenShortCut {Param ($FullName)
	$Shell = New-Object -ComObject WScript.Shell
	$Shortcut = $Shell.createshortcut($FullName)
	Return $Shortcut
}
Function CreateShortcut {Param ($FullName, $Arguments, $Description, $HotKey, $IconLocation = $null, `
		$RelativePath, $TargetPath, $WindowStyle, $WorkingDirectory)
	$Shell = New-Object -ComObject WScript.Shell
	$Shortcut = $Shell.CreateShortcut($FullName)
	$Shortcut.Arguments = $Arguments
	$Shortcut.Description = $Description
	$Shortcut.HotKey = $HotKey
	If ($IconLocation -ne $null) {$Shortcut.IconLocation = $IconLocation}
	$Shortcut.TargetPath = $TargetPath
	$Shortcut.WindowStyle = $WindowStyle
	$Shortcut.WorkingDirectory = $WorkingDirectory
	$Shortcut.Save()
	Return $Shortcut
}
Function InputBox {Param($Prompt, $title, $default)
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')  
	$Input = [Microsoft.VisualBasic.Interaction]::InputBox($prompt, $Title, $default)
	Return $Input
}
Function SelectFolder {Param($hwnd = 0, 
		$Title = 'Open Folder', 
		$options = 0, 
		$RootFolder = $(Get-SpecialFolders).Desktop)
	$sh = New-Object -ComObject Shell.Application
	$folder = $sh.BrowseforFolder($hwnd, $Title, $options, $RootFolder)
	Return $folder
}
Function MsgBox {Param($Prompt, $style = 0, $title)
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')  
	$Input = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt, $Style, $Title)
	Return $Input
}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuQbmgUX9G3Xn4pyrNrJB13da
# SE2gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FAXxYB+/ZLnIsdXWA+sgDxrVF/CIMA0GCSqGSIb3DQEBAQUABIGAVXqc2xqO+DLG
# tsUQOgQVB8EaDzMINrQxH90RSDhiZcQJOVWIwl+QNsVPmbKFEt4g7YTO86arYOub
# rjWll2vnHRG1Gmn+FsKx5LwHOSSC4NqWGTYrrpzhT2zJLfT4FjqMsC1eEIHLxrru
# iFALYcBQgWXsqhgJXnjELVwNX4NIuFM=
# SIG # End signature block
