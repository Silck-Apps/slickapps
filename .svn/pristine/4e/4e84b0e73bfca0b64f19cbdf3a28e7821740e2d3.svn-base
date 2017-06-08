<?php
$dbuser="bennettw";
$dbpass="sambo174";
$dbhost="ispcfg01";
$db="dbispconfig";
$query="truncate sys_log;";

$mysqli = new mysqli("$dbhost", "$dbuser", "$dbpass", "$dbl");

/* check connection */
if ($mysqli->connect_errno) {
    printf("Connect failed: %s\n", $mysqli->connect_error);
    exit();
}
echo $mysqli->query("$query")
if ($mysqli->query("$query") === TRUE) {

}
else {

}
?>