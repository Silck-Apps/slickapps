<?php
	$script="/srv/resources/scripts/mysql/repair_replication.sh";
	$dumpopt="-d";
	$delopt="-drl";
	$precmd="echo 'R1m@dmin' | sudo -S";
	$statusscript="/srv/resources/scripts/mysql/replication_status.sh";
	$option=$_POST['mysqlopts'];
	$button=$_POST['mysql_submit'];
	if ("$button" == "Status") {
		$message=shell_exec($statusscript);
	}
	else {
		switch ($option) {
			case "NULL":
				$cmd=$script;
				break;
			case "dump":
				$cmd=$precmd.' '.$script.' '.$dumpopt;
				break;
			case "del":
				$cmd=$precmd.' '.$script.' '.$delopt;
				break;
		}	
		$message=shell_exec($cmd);
	}
?> 
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="style.css">
</HEAD>
<BODY>
<?php print '<pre><div id="output">'.$message.'</div></pre>' ?>
</BODY>
</HTML>