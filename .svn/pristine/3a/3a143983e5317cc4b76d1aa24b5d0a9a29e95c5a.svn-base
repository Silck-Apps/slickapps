Param ($Group, [switch]$FirstRun, $Path = "\\parma.internal\dfsroot\GBS\helpdesk\scripts\GeneratedData-Temp\")
$ScriptsDir = $MyInvocation.MyCommand.Path
$ScriptsDir = $ScriptsDir.Replace($MyInvocation.MyCommand.Name,'')
$SysDir = ($ScriptsDir.Replace('HelpDesk\','') + 'common')
. ($SysDir + '\ADFunctions.ps1')
$filepath = $path + $Group + " Group Membership Details.xls"

#*************************** FUNCTIONS *****************************
Function Prepare-SpreadSheet { Param ($Group, $filepath)
	


}



#***************************END FUNCTIONS*********************************

If ($FirstRun.IsPresent -eq $true) {Prepare-SpreadSheet -Group $Group -filepath $filepath -Excel $Excel}
