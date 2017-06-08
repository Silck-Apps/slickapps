<?php
$precmd="echo 'R1m@dmin' | sudo -S";
$script="ssh rt01 '/srv/resources/scripts/requesttracker/control-service.sh -a restart'";
$cmd=$precmd.' '.$script;
$msg=shell_exec($cmd);
?>
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="style.css">
</HEAD>
<BODY>
<?php print '<pre><div id="output">'.$msg.'</div></pre>' ?>
</BODY>
</HTML>