Function SetPermissions {Param ($HomePath, $UserName, `
		$Rights = 'Modify', `
		$Access = 'Allow', `
		$Inherit = "ContainerInherit,ObjectInherit", `
		$Prop = "None")
	$ACL = Get-Acl -Path $HomePath
	$AccessRule = New-object system.security.accesscontrol.filesystemaccessrule($Username,$Rights,$Inherit,$Prop,$Access)
	$ACL.SetAccessRule($AccessRule)
	Set-Acl -Path $HomePath -AclObject $ACL 
}
Function SignScript {Param ($FilePath)
	$cert = Get-ChildItem cert:\LocalMachine\TrustedPublisher -codesigningcert
	$Result = Set-AuthenticodeSignature -Certificate $cert -FilePath $FilePath
	Return $Result
	}
Function SignAll {Param ($Dir, $LogFile = ($LogFile + 'ScriptSigning.Log'))
	If ((Test-Path $LogFile) -eq $true){Remove-Item -Path $LogFile -Force}
	ForEach ($item in (Get-ChildItem -Path $Dir -Filter '*.ps1' -Recurse)){
		$Result = SignScript -FilePath $item.FullName
		$Result | Out-File $LogFile -Append -NoClobber
		If ($Result.status -contains 'UnknownError'){'Converting File ' + $Result.Path + ' To UTF-8 format...' | Out-File $LogFile -Append -NoClobber
			$Content = Get-Content $Result.Path
			Out-File $Result.Path -Encoding utf8 -InputObject $Content -Force
			'Attempting to Sign Again....' | Out-File $LogFile -Append -NoClobber
			$Result = SignScript -FilePath $item.fullname | Out-File $LogFile -Append -NoClobber
			$Result | Out-File $LogFile -Append -NoClobber}
		}
	}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUV6a1LZ594LACL9hNXoeniGCO
# mvqgggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FFXIjQuQzkSFYe48nbG/nXsHQ5dnMA0GCSqGSIb3DQEBAQUABIGAKeeUukgJWxiD
# pp7Gi+e6DYcvPXWpDSo2ej0/EhNrekxhtZVx7+Q/8LIpQ/U9XjecVpHB98xzwbin
# loSGFciDZJMIWzuarLvuu2ZBBs61jgvw77DFGLXop/7BhoTEoG/F+HLqfTpOzLgl
# 96JxaAplXOk22QvUf5OnbbUU00vMTaI=
# SIG # End signature block
