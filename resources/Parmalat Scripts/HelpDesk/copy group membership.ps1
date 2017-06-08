Param ([Switch]$Change, [Switch]$Save, [Switch]$NoSecurityGroups, [Switch]$Help,
	$CopyUser = $null,
	$EditUser = $null)
Function HelpFile {
	Write-Host '*************************************************************************************'
	Write-Host '**************************     Save or Copy Group Memberships tool ***********************'
	Write-Host ' *************************************************************************************'
	Write-Host ' Log FIle Location: "' $LogFile '"'
	Write-Host '         **  Required Parameter'
	Write-Host '               "-CopyUser" -- This should be the user name of the user you want to'
	Write-Host '                              Save or copy the changes to be made from.'
	Write-Host '**************************  Required Switches  ************************'
	Write-Host '  You must specify one of the following switches:'
	Write-Host '           ** "-Change" -- Tells the Script that you want to replace group memberships for the'
	Write-Host '                               User supplied with the "-EditUser" Parameter.'
	Write-Host '                   ** Required Parameter: "-EditUser" -- The user name of the user you wish '
	Write-Host '                                              to make the changes to'
	Write-Host '          ** "-Save" -- Tells the script that you want to save a list of group memberships that apply'
	Write-Host '                               to the user supplied by the "-CopyUser" parameter'
	Write-Host '                     ** Optional Switch: "-NoSecurityGroups" -- supply this switch to ommit Security'
	Write-Host '                                                         groups from the exported list'
	Write-Host '                                       - Only valid without "-Change" Parameter'
	Write-Host '        ** "-Help" -- Displays this help file'
	Write-Host '-------------------------------------------------------------------------------------------------------'
	Write-Host ' -------------------------       Usage Examples       ----------------------------------------'
	Write-Host ' Simple Usage:'
	Write-Host '       -CopyUser "User1" -Change -EditUser "User2"'
	Write-Host '      -CopyUser "User1" -Save'
	Write-Host ' Full Usage:'
	Write-Host '      -CopyUser "User1" -Change -EditUser "User2" -Save'
	Write-Host '      -CopyUser "User1" -Save -NoSecurityGroups'
	Write-Host '**************************************************************************************'
	Exit
}
Trap {Write-Host $_.Exception.Message
	$_.Exception.Message | Out-File -FilePath $LogFile -Append -NoClobber
	Write-Host ('Script Line Number: ' + $_.Invocationinfo.ScriptLineNumber)
	'Script Line Number: ' + $_.Invocationinfo.ScriptLineNumber | Out-File -FilePath $LogFile -Append -NoClobber
	Write-Host ('Command: ' + $_.InvocationInfo.invocationname)
	'Command: ' + $_.InvocationInfo.invocationname | Out-File -FilePath $LogFile -Append -NoClobber
	Switch ($_.CategoryInfo.Category){
		'OperationStopped' {
			'*********************   End of Entry   ******************' | Out-File -FilePath $LogFile -Append -NoClobber			
			Exit
		}
		Default {Continue}
	}
}
Clear-Host
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
$LogFile = '\\parma.internal\dfsroot\GBS\HelpDesk\Scripts\Logs\copy group memberships.log'
If ($Help.IsPresent -eq $true) {HelpFile}
Import-Module activedirectory
. ($SysDir + '\ADFunctions.ps1')
. ($SysDir + '\WindowsForms.ps1')
'*******************   New Entry   ********************' | Out-File -FilePath $LogFile -Append -NoClobber
'Script ran by: ' + $env:USERNAME | Out-File -FilePath $LogFile -Append -NoClobber
If ($CopyUser -eq $null) {Throw '-CopyUser: A User Name Must be entered!'}
$match = validateADUser $CopyUser
#If ($match -eq $false) {Throw 'User Name not found in Active Directory. Please check and try again.'}
'User Name "' + $CopyUser + '" Is valid. This user''s memberships will be copied...' | Out-File -FilePath $LogFile -Append -NoClobber
$reqswitches = $false
If ($Change.IsPresent -eq $true) {
	'Changing User permissions...' | Out-File -FilePath $LogFile -Append -NoClobber
	$reqswitches = $true
	If ($Save.IsPresent -eq $true) {
		'Saving List of groups' | Out-File -FilePath $LogFile -Append -NoClobber
		If ($NoSecurityGroups.IsPresent -eq $true) {'No Security Groups listed in Exported file' | Out-File -FilePath $LogFile -Append -NoClobber}
	}
}
If ($reqswitches -eq $false) {
	If ($Save.IsPresent -eq $true) {
		'Saving List of groups' | Out-File -FilePath $LogFile -Append -NoClobber
		$reqswitches = $true
		If ($NoSecurityGroups.IsPresent -eq $true) {'No Security Groups listed in Exported file' | Out-File -FilePath $LogFile -Append -NoClobber}
	}
}
If ($reqswitches -eq $false) {Throw 'Required Switches not present. Must supply "-Change" and/or "-Save" Parameters'}
$CopyUser = Get-ADUser -Identity $CopyUser
$groups = func_copyuser $CopyUser.DistinguishedName
If ($Change.IsPresent -eq $true) {
	If ($EditUser -eq $null) {Throw '-EditUser: A User Name Must Be Entered!'}
	$match = validateADuser $EditUser
#	If ($match -eq $false) {Throw 'User Name not found in Active Directory. Please check and try again.'}
	'User Name "' + $EditUser + '" Is valid. This user''s memberships will be modified...' | Out-File -FilePath $LogFile -Append -NoClobber
	$EditUser = Get-ADUser -Identity $EditUser
	$oldgrps = func_copyuser $EditUser.DistinguishedName
	Write-Host 'Removing old groups....'
	'Removing old groups.....' | Out-File -FilePath $LogFile -Append -NoClobber
	Write-Host ''
	'' | Out-File -FilePath $LogFile -Append -NoClobber
	ForEach ($grp in $oldgrps) {
		$(Get-ADGroup -Identity $grp).name | Out-File -FilePath $LogFile -Append -NoClobber
		Write-Host $(Get-ADGroup -Identity $grp).name
		Remove-ADGroupMember -Identity $grp -Members $EditUser.SAMAccountName}
	Write-Host ''
	'' | Out-File -FilePath $LogFile -Append -NoClobber
	Write-Host 'Ading New groups...'
	'Adding New Groups.....' | Out-File -FilePath $LogFile -Append -NoClobber
	Write-Host ''
	'' | Out-File -FilePath $LogFile -Append -NoClobber
	ForEach ($grp in $groups) {Write-Host $(Get-ADGroup -Debug $grp).name
		$(Get-ADGroup -Debug $grp).name | Out-File -FilePath $LogFile -Append -NoClobber
		Add-ADGroupMember -Identity $grp -Members $EditUser.SAMACcountName}
}
If ($Save.IsPresent -eq $true) {
	$output = @()
	If ($Change.IsPresent -eq $true) {
		$Distgrps = @()
		$Secgrps = @()
		$Distgrps = Listgroups -DistributionGroups -Groups $groups
		$Secgrps = Listgroups -SecurityGroups -Groups $groups
		$output += '********************************'
		$output += 'User Being Copied: ' + $CopyUser.SamAccountName
		$output += '********************************'
		$output += ' Distribution Groups....'
		$output += $Distgrps
		$output += '***************************'
		$output += ' Security Groups....'
		$output += $Secgrps
		$Distgrps = @()
		$Secgrps = @()
		$Distgrps = Listgroups -DistributionGroups -Groups $oldgrps
		$Secgrps = listgroups -SecurityGroups -Groups $oldgrps
		$output += '********************************'
		$output += 'User to apply changes to: ' + $EditUser.SamAccountName
		$output += 'Users old group memberships are...'
		$output += '********************************'
		$output += ' Distribution Groups.....'
		$output += $Distgrps
		$output += '*******************************'
		$output += ' Security Groups.....'
		$output += $Secgrps
	}
	Else {$Distgrps = $null
		$Secgrps = $null
		$Distgrps = ListGroups -DistributionGroups -groups $groups
		$Secgrps = ListGroups -Securitygroups -groups $groups
		$output += '********************************'
		$output += 'User name: ' + $CopyUser.SamAccountName
		$output += 'User''s group memberships follow...'
		$output += '**********************************'
		$output += '*******  Distribution Groups  ********'
		$output += $Distgrps
		If ($NoSecurityGroups.IsPresent -eq $false) { 
			$output += '********** Security Groups   **********'
			$output += $Secgrps
		}
		$output += ' *********************************'
	}
	$File = SaveFIleAs -Filter 'Text Files (*.txt)|*.txt*|All Files (*.*)| *.*' `
		-InitialDirectory $env:TEMP -Title 'Save File...' -FileName 'groups.txt'
	Out-File -FilePath $File[1] -InputObject $output
}
'************************    End of Entry   ************************' | Out-File -FilePath $LogFile -Append -NoClobber
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnCJ6D+R1Vjzl56xmQbHxFfol
# g52gggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FEfM688f//4pvRapd19Cz/wI+MJeMA0GCSqGSIb3DQEBAQUABIGAqUJRmUXRZUQM
# pII+nTk2/BF2geqwb7qGhEX5sc7vBjqSHfeULAI6MQahliuErMNl4SYqZnJ7x7xD
# 0JzNb8hhvrzZ5LLHr4NpasvK1vtOnCUzb27KP2HuiRu1OEUYmiYRTooqnG7wjjN+
# seUmeP4kG/VkNYykXedFnzEsYHwrJ04=
# SIG # End signature block
