Function OpenFile{Param($Filter = 'All Files (*.*)| *.*', `
		$FilterIndex, `
		$DefaultExt, `
		$Title = "Open File", `
		$InitialDirectory)
	[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
	$OpenFile = New-Object Windows.Forms.OpenFileDialog
	$OpenFile.ShowHelp = $true
	$OpenFile.Filter = $filter
	$OpenFile.FilterIndex = $FilterIndex
	$OpenFile.initialdirectory = $InitialDirectory
	$OpenFile.DefaultExt = $DefaultExt
	$OpenFile.MultiSelect = $false
	$OpenFile.RestoreDirectory = $true
	$OpenFile.Title = $Title
	$OpenFile.ValidateNames = $true
	$OpenFile.ShowDialog()|Out-Null
	Return $OpenFile.filename
}
Function SaveFileAs{Param($Filter = 'All Files (*.*)| *.*', `
		$FilterIndex, `
		$Title = "Open File", `
		$InitialDirectory, $FileName)
	[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
	$OpenFile = New-Object Windows.Forms.SaveFileDialog
	$OpenFile.Filter = $filter
	$OpenFile.FilterIndex = $FilterIndex
	$OpenFile.initialDirectory = $InitialDirectory
	$OpenFile.Title = $Title
	$OpenFile.FileName = $FileName
	$OpenFile.ShowDialog()|Out-Null
	Return $OpenFile.filename
}

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJhgBeSU4KeTmnYW7aPW8rrQS
# QHGgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FA4bueFOuKn/EQLrlLrK1RIDX13gMA0GCSqGSIb3DQEBAQUABIGAfZ8Vut6xUqiB
# eEsPl1ERw1r4fTn5NGTJfU6rL08g9F/jkBVKMLr7k27cubifBR9sJWdFA7teGYFG
# 2K09dYnEqPewfsQbzcoN/noGeVyGbgfjY0Mme4eKNupO+1b1nCKyPgBryvbMPMEw
# C3mKaJPUtHR8WQlkEcbaePaIPpj4M+k=
# SIG # End signature block
