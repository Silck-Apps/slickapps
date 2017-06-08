<?php
$dbuser="scripts_data";
$dbpass="new12day";
$dbhost="mysql.skdk.internal";
$db="scripts_data";
$service="mysql_replication";

$query="select server from monitor_services where $service is true";
$statusquery="show slave status\G";

$mysqli = new mysqli("$dbhost", "$dbuser", "$dbpass", "$db");
/* check connection */
if ($mysqli->connect_errno) {
	printf("Connect failed: %s\n", $mysqli->connect_error);
	exit();
}

$servers=$mysqli->query($query);
while ($row = $servers->fetch_array(MYSQLI_ASSOC)) {
	$server=$row["server"];	
	echo $server;
	$mysqli = new mysqli("$server", "$dbuser", "$dbpass", "$db");
	/* check connection */
	if ($mysqli->connect_errno) {
		printf("Connect failed: %s\n", $mysqli->connect_error);
		exit();
	}
	$slavestatus=$mysqli->query($statusquery);
	while ($srow = $slavestatus->fetch_array(MYSQLI_ASSOC)) {
		switch ($srow) {
			case "Slave_IO_Running":
				$iostatus=$srow;
				break;
			case "Slave_SQL_Running":
				$sqlstatus=$srow;
				break;
			case "Slave_IO_State":
				$slavestatus=$srow;
				break;
		}
echo $iostatus;
echo $sqlstatus;
echo $slavestatus;
}
}




?>