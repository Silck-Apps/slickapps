############################################################################################################################################
############################################################################################################################################
#					User Files Migration Utility
#
#		Written By: 	Wayne Bennett
#		When:	June 2011
#		Why:	The Help Desk needed to be able to accuratly and quickly migrate users files from their PS4 Parma Apps Desktop to the XenApp Desktop.
#
############################################################################################################################################
############################################################################################################################################
#--------------------   Script Parameters --------------------------------
Param ($Username = '\\parma.internal\dfsroot\gbs\helpdesk\Scripts\PS4-Xen\UsersTOMigrate.txt', 
	$SourceDir = $null,
	$DestDir = 'My Documents',
	$Ignore = $null,
	[Switch]$RemoveInvalidShortcuts,
	$AppendToName = '_UserMigration',
	[Switch]$XenAppMigration,
    $LogFile = 'Migrate User Files',
	[Switch]$Help,
	$ShortcutLocation = $null,
	[Switch]$CreateShortcut)
#----------------------------------------------------------------------------------------------
#----------------------  Display Help Dialoge   --------------------------------------#
Function ShowHelp {
	Write-Host '*************   User Files Migration Tool ********************** '
	Write-Host ''
	Write-Host ' This script moves a user''s data from one directory on their M drive to another.'
	Write-host 'It can also perform a Migration of users desktop from PS4 to XenApps'
	Write-Host 'There are no required parameters for this tool'
	Write-Host ''
	Write-Host ' Available parameters....'
	Write-Host '	-XenAppMigration: Use this switch to perform a XenAppMigration.'
	write-host '		All options are "Hard coded" Any parameters supplied'
	write-host '		(Except for the username parameter) are ignored.'
	Write-Host ''
	Write-Host '	-UserName: Default Value: "'$Username'"'
	Write-Host '		Specify the path to a text file that has one user name per'
	write-host '			line or a single user name. This parameter is the'
	write-host '			only one that can be used with the'
	Write-Host '			"-XenAppMigration" switch'
	Write-Host '	-SourceDir: Default value: M drive root (EG: \\fs3\bennettw$)'
	Write-Host '		Specifies the directory to move data from'
	write-host '			(Must be in the user''s M drive)'
	Write-Host '	-DestDir Default Value : "'$DestDir'"'
	Write-Host '		Specifies the directory to move data to'
	Write-host '			(Must be in the user''s M drive)'
	Write-Host '	-Ignore: Specify a Comma delimited list of crieteria to ignore'
	Write-Host '		from the move. This could be partial names, extensions only'
	Write-Host '		or anything else.'
	Write-Host '		EG: ''"windows",".lnk",".ica","my documents","Personal files"'''
	Write-Host '	-RemoveInvaliShortcuts: Specify this switch to test for the target of'
	Write-host '		any shortcuts found. If the target doesn''t exist then delete it.'
	Write-Host '	-AppendToName: Default Value: "'$AppendToName'"'
	Write-Host '		A string to add to the file name being copied if the destination'
	Write-host '		name already exists'
	Write-Host '	-LogFile: Default value: "'$LogFile'"'
	Write-Host '		Writes a log to this location'
	Write-Host '	-CreateShortcut: Specify ths switch to create a shortcut to the'
	Write-host '			data being moved'
	Write-Host '		-ShortcutLocation: Default Value: "'$ShortcutLocation'"'
	Write-Host '			Specify this parameter with "CreateShortcut" to change'
	Write-host '			the location the shortcut is created in'
	Write-Host ''
	Write-Host '****************************************************************************'
	Exit
}


#----------------------   Error Handler   -------------------------------------------------
Trap {$Msg = $_.Exception.Message; $Line = $_.InvocationInfo.ScriptLineNumber; $cmd = $_.InvocationInfo.InvocationName
$LogString = @"
$Msg
Script Line Number: "$Line"
Command: "$Cmd"
"@
Write-EventLog -EntryType Error -EventId 3 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
	Switch ($_.CategoryInfo.Category){
		'OperationStopped' {Write-EventLog -EntryType Error -EventId 1 -Message 'Operation Halted' -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
			$ErrorActionPreference = $Errorpref
			Exit
		}
		'ObjectNotFound' {Write-EventLog -EntryType Error -EventId 1 -Message 'UserName Parameter is invalid.' -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
			$ErrorActionPreference = $Errorpref
			Exit
		}
	default {Continue}
	}
}
#---------------------------------------------------------------------------------------------

#------------------------- Functions ------------------------------------------------------------------

#---------------------------------- ProcessUser -----------------------------------------------
# Process User evaluates each item in the Source Dir and moves it to the Dest Dir.
# -Username: Username to work on
# -$SourceDir: Directory to evaluate
# -DestDir: Directory to move items to
# -Ignore: CSV of search criteria to not include in the move
# -RemoveInvalidShortcuts: If specified test's shortcut target validity and deletes the shortcut if target doesn't exist.
# -AppendToName: String to append to file name if destination filename already exists
# -XenAppMigration: Specify to migrate a users desktop and favorites to XenApp
Function ProcessUser {Param($Username, $SourceDir, $DestDir, $Ignore, $RemoveInvalidShortcuts, $AppendToName, $XenAppMigration)
	#----------  Is the a XenApp Migration?
$LogString = @"
User being operated on: "$Username"
Script Ran by: "$Env:Username"
Ignore filter: "$Ignore"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
	If ($XenAppMigration.IsPresent -eq $true) {XenAppMigration -Username $Username}
	# -------- Set initial variables
	Else {
		$HomeDir = $(Get-aduser -Identity $Username -Properties 'HomeDirectory').HomeDirectory
		$SourceDir = $HomeDir + '\' + $SourceDir
		$DestDir = $HomeDir + '\' + $DestDir
		$files = Get-ChildItem -path $SourceDir
		If ((Test-Path $SourceDir) -eq $false) { Throw '"' + $SourceDir + '" Doesn''t Exist. Operation Halted!'}
		If ((Test-Path $DestDir) -eq $false) { 
$LogString = @"
"$DestDir" Does not exist. 
Creating Directory...
"@
			Write-EventLog -EntryType Warning -EventId 1 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
			New-Item -ItemType 'Directory' -Path $DestDir 
			}
		#-------------   Does file match ignore list?
		ForEach ($File in $files){
			ForEach($Condition in $Ignore){$match = $false
				If ($File -like $Condition) {$Match = $True; break}
			}
			If ($match -eq $true) {$LogString = @"
Ignoring the following files: "$File"
"@
			Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'}
			#------------------  Is this file a shortcut?
			Else { If ($file.extension -like '.lnk') {
					If ($RemoveInvalidShortcuts.IsPresent -eq $true) {
						$Shortcut = OpenShortcut $File.FullName # insert switch to test targetpath for Programs and ignore
						$Exists = testtarget $Shortcut.TargetPath
						If ($Exists -eq $false) {$str = $File.Name; $LogString = @"
Invalid Shortcut: "$str" Removing...
"@
							Write-EventLog -EntryType Warning -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
							Remove-Item -Path $File.FullName -Force}
					}
					Else {$Str = $File.Name; $LogString = @"
Copying "$str" to "$DestDir"
"@
						Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
						Copy-Item -Path $File.fullname -Destination $DestDir -Force}
				}
				Else {$newFileName = New-Object -TypeName PSObject -Property @{
						BaseName = $File.BaseName
						Extension = $File.Extension
						Name = $File.Name}	
					If ((Test-Path $($DestDir + '\' + $File.name)) -eq $true) {
					$newFileName.BaseName = $file.BaseName + $AppendToName
					$newFileName.Name = $file.BaseName + $AppendToName + $File.extension
					$Str = $File.Name; $str1 = $newFileName.Name; $LogString = @"
Destination File Exists. Renaming "$str" to "$str1"
"@
Write-EventLog -EntryType Warning -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
					}
				Rename-Item -Path $File.FullName -NewName $newFileName.Name
				$LogString = @"
Moving item: "$str1" to "$DestDir"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
				#Move item to Mydocs
				Move-Item -Path $($SourceDir + '\' + $newfilename.Name) -Destination $DestDir -force
				If ($CreateShortcut.IsPresent -eq $true) {
					If ($ShortcutLocation -eq $null) {$ShortcutLocation = $HomeDir + '\Desktop'}
				#Create shortcuts on both desktops
					$Result = CreateShortcut -FullName ($ShortcutLocation + '\' + $newFileName.BaseName + '.lnk') -TargetPath $($DestDir + '\' + $newFileName.Name)
					$Str = $Result.FullName; $LogString = @"
Creating a shortcut here: "$str"
"@
					Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
					}
				}
			}
		}
	}
}	
#----------------------------------------------------------------------------------------
#-------------------------- Test Target --------------------------------
# THis one replaces Drive letter references with UNC paths.
# Exists is one of three results
# 1: true (Default)
# 2: False
# 3: Ignore: this value is set if target is C: or D: drives
Function TestTarget {Param ($TargetPath)
	$Exists = $true
	Switch ($TargetPath.substring(0,2)) {
		'\\' {If ((Test-Path $TargetPath) -eq $false) {$Exists = $false}}
		'O:' {$TargetPath = $TargetPath.Replace('O:','\\parma.internal\dfsroot')
			If ((Test-Path $TargetPath) -eq $false) {$Exists = $false}}
		'Q:' {$TargetPath = $TargetPath.Replace('Q:','\\parma.internal\dfsroot\Brisbane')
			If ((Test-Path $TargetPath) -eq $false) {$Exists = $false}}
		'S:' {$TargetPath = $TargetPath.Replace('S:','\\parma.internal\dfsroot\Software')
			If ((Test-Path $TargetPath) -eq $false) {$Exists = $false}}
		'M:' {$TargetPath = $TargetPath.Replace('M:','\\parma.internal\dfsroot')
			If ((Test-Path $TargetPath) -eq $false) {$Exists = $false}}
		'C:' {$Exists = 'Ignore'}
		'D:' {$Exists = 'Ignore'}
		default {$Exists = $true}
		}
	Return $Exists
}
#--------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------- XenAppMigration -------------------------------------------------------------------------------
# XenAppMigration is setup to migrate a user's desktop folder and favorites to XenApp. Performs the following tasks:
# 	1: If M:\Desktop and M:\Favorites don't exist they are created
#	2: Moves all files on desktop to My documents folder (Ignores Shortcuts)
#	3: Test's the validity of all desktop shortcuts. If the target dosen't exist the shortcut is deleted
#	4: Copies all valid shortcuts to the XenApp Desktop folder
#	5: Creates new shortcuts on both Desktop folders for all files and folders moved to My documents folder
#	6: Copies all favorites to M:\favorites
Function XenAppMigration {Param ($Username)
	#--------------- Set initial variables
	$HomeDir = $(Get-aduser -Identity $Username -Properties 'HomeDirectory').HomeDirectory
	$PS4Desktop = $HomeDir + '\Windows\Desktop'
	$XenDesktop = $HomeDir + '\Desktop'
	$PS4Favs = $HomeDir + '\Windows\Favorites'
	$XenFavs = $HomeDir + '\Favorites'
	$MyDocs = $HomeDir + '\My Documents'
	$files = Get-ChildItem -Path $PS4Desktop
	$Ignore = '"*.ica","*.cmd","*.bat","*.rdp","*.vnc","*.sap"'
	$Ignore = ProcessList $Ignore
	#---------------- Test variables, Create any folders required
	Write-EventLog -EntryType Information -EventId 0 -Message 'Xen App Migration: True' -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
	If ((Test-Path $PS4Desktop) -eq $false) {Throw 'PS4Desktop Doesn''t Exist. Operation Halted!'}
	If ((Test-Path $XenDesktop) -eq $false) {$LogString = @"
Creating XenApp Desktop Folder: "$XenDesktop"
"@
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
		New-Item -ItemType 'Directory' -Path $XenDesktop
		}
	If ((Test-Path $XenFavs) -eq $false) {$LogString = @"
Creating Favorites Folder: "$XenFavs"
"@
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
		New-Item -ItemType 'Directory' -Path $XenFavs
		}
	If ((Test-Path $MyDocs) -eq $false) {$LogString = @"
Creating My Documents Folder: "$MyDocs"
"@
		Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
		New-Item -ItemType 'Directory' -Path $MyDocs
		}
	# ------------- Process Files
	ForEach ($File in $Files) {
		# Is this file a shortcut??
		If ($File.Extension -match '.lnk') {
			$Shortcut = OpenShortcut $File.FullName # insert switch to test targetpath for Programs and ignore
			$Exists = testtarget $Shortcut.TargetPath
		#Test Exists and perform action
			Switch ($Exists) {
				$false {$str = $File.Name; $Logstring = @"
Invalid Shortcut: "$Str" Removing...
"@
					Write-EventLog -EntryType Warning -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
					Remove-Item -Path $File.FullName -Force
					Remove-Item -Path ($XenDesktop + '\' + $File.Name) -Force
				}
				'Ignore' {$str = $File.Name; $LogString = @"
"$str" has been ignored. It points to a program...
"@
					Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'}
				Default{ 'Copying ' + $File.name + ' to ' + $XenDesktop  | Out-File -FilePath $LogFile -Append -NoClobber
					Copy-Item -Path $File.fullname -Destination ($XenDesktop + '\' + $File.Name) -Force
			}
			}
		}
		# If file isn't a shortcut then test mydocs for file of same name
		Else {$newFileName = New-Object -TypeName PSObject -Property @{
				BaseName = $File.BaseName
				Extension = $File.Extension
				Name = $File.Name
				}
			ForEach ($Condition in $Ignore) {$match = $false
				If ($File.name -like $Condition) {$match = $true; break}
			}
			If ($Match -eq $true) { $str = $File.Name; $LogString = @"
"$str" matches "$Condition" Item copied to XenDesktop...
"@
				Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
				Copy-Item -Path $File.FullName -Destination $XenDesktop -Force				
			}
			# file exists in mydocs then rename file to be moved
			Else {If ((Test-Path ($MyDocs + '\' + $File.Name)) -eq $true) { 
					$newFileName.BaseName = $file.BaseName + $AppendToName
					$newFileName.Name = $file.BaseName + $AppendToName + $File.extension
					$str = $File.Name; $Str1 = $newFileName.Name; $LogString = @"
Destination File Exists. Renaming "$str" to "$str1"
"@
					Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
					}
				Rename-Item -Path $File.FullName -NewName $newFileName.Name
				$LogString = @"
Moving item: "$Str1" to "$MyDocs"
"@
				Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
				#Move item to Mydocs
				Move-Item -Path $($PS4Desktop + '\' + $newFileName.Name) -Destination $MyDocs -force
				#Create shortcuts on both desktops
				Write-EventLog -EntryType Information -EventId 0 -Message 'Creating PS4 Desktop shortcut...' -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
				$Result = CreateShortcut -FullName ($PS4Desktop + '\' + $newFileName.BaseName + '.lnk') -TargetPath $($MyDocs + '\' + $newFileName.Name)
				Write-EventLog -EntryType Information -EventId 0 -Message 'Creating Xen Desktop Shortcut...' -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
				$Result = CreateShortcut -FullName ($XenDesktop + '\' + $newFileName.BaseName + '.lnk') -TargetPath $($MyDocs + '\' + $newFileName.Name)
			}		
		}
	}
#Copy Favorites
$LogString = @"
Copying contents of "$PS4Favs" to "$XenFavs"
"@
Write-EventLog -EntryType Information -EventId 0 -Message $LogString -LogName $LogFile -Source 'Migrate User Files ver 3.ps1'
Copy-Item -Path $($PS4Favs + '\*') -Destination $XenFavs -Recurse -Force
}
#-----------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------- End of Functions section -----------------------------------

#------------------------------------- Script Start ------------------------------------------------------
#-------------------------------- Initalise Script
Clear-Host
$Error.Clear()
$Errorpref = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\vbFunctions.ps1')
. ($SysDir + '\Powershell.ps1')
$UsernamesFile = $Username
$Ignore = ProcessList $Ignore
Import-Module ActiveDirectory
# Display Help if present
If ($help.IsPresent -eq $true) {ShowHelp}

#--------------- is the "UserName" Parameter a UserName or FIle Path?
$match = $null
$match = Test-Path $Username
If ($match -eq $true) {
	$UsernamesFile = Get-Content $Username
		$multiple = $true
		If ($UsernamesFile -eq $null) {Throw 'No Usernames in File. Operation Completed.'}
	}
Else {$Match = $null
	$multiple = $false
	$match = Get-ADUser -Identity $Username
	If ($match -eq $null) {Throw 'UserName Parameter is invalid.'}
	}
#Process Users
If ($multiple -eq $false) {ProcessUser -userName $Username `
	-AppendToName $AppendToName `
	-DestDir $DestDir `
	-Ignore $Ignore `
	-RemoveInvalidShortcuts $RemoveInvalidShortcuts `
	-SourceDir $SourceDir `
	-XenAppMigration $XenAppMigration
	}
Else { ForEach ($Name in $UsernamesFile) {ProcessUser -Username $Name `
		-AppendToName $AppendToName `
		-DestDir $DestDir `
		-Ignore $Ignore `
		-RemoveInvalidShortcuts $RemoveInvalidShortcuts `
		-SourceDir $SourceDir `
		-XenAppMigration $XenAppMigration
		}
	#Rename and re-create blank username file
	[string]$stamp = Get-Date -Format dd-MM-yyyy_HH-mm-ss
	$newname = $stamp + '_Migrated Users.txt'
	Rename-Item -Path $Username -NewName $newname -Force
	New-Item -ItemType 'file' -Path $UserName
	}
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJb88hhSHSOu8aQ8E9aoSe2uc
# 5FegggI9MIICOTCCAaagAwIBAgIQ7bP7ToVimIhEHCXvh6Y5IjAJBgUrDgMCHQUA
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
# FCwg4vCfgPwGI3le/naSFtFl8dfkMA0GCSqGSIb3DQEBAQUABIGAaD3T7NcKrs26
# Djko4bD4/GMh6I7Vr1HuAW9Dy+gOeLRrx2R4n/Kgh4vfIAQ11zeTFl0vgzy5Ez+2
# EzeqfVkKt1fLi1g5uKXwU8yvQYy2HJBOP00kYnYDnuC+JVjgRf1lY3qQMgqFWSj4
# ConF2ycIOXf5ahDyyrQ1231A0ZZZqnU=
# SIG # End signature block
