<?php
$dbuser="scripts_data";
$dbpass="new12day";
$dbhost="mysql";
$db="scripts_data";
# $query="truncate sys_log;";
?>
<HTML>
<HEAD>
<link rel="stylesheet" type="text/css" href="style.css">
</HEAD>
	<BODY>
		<div id="default">
			<H1>
				Local Host Web Hosting Control Room
			</H1>
			<form id="mysql" action="repair-sql-replication.php" method="post">
				<H2>MySQL Replication</H2>
				<p><LABEL>
					Dump Databases:
				</LABEL>
				<input type="radio" name="mysqlopts" value="dump">
				<label>
					Delete Logs: 
				</label>
				<input type="radio" name="mysqlopts" value="del">
				<label>
					None: 
				</label>
				<input type="radio" name="mysqlopts" checked value="NULL">
				</P>
				<input type="Submit" name="mysql_submit" value="Repair";>
				<input type="Submit" name="mysql_submit" value="Status";>
			</form>
			<form id="rt" action="restart-rt.php" method="post">
				<H2>Request Tracker</H2>
				<div id="formbox">
					<input type="submit" name="rt_submit" value="Restart">
				</div>
			</form>
			<form id="clear_isp_syslog" action="clear-syslog.php" method="post">
				<H2>Clear Ispconfig Syslog</H2>
				<div id="formbox">
					<input type="submit" name="clear_syslog" value="Clear Syslog">
				</div>
			</form>
			<form id="restart_vm" action="restart-vm.php" method="post">
				<H2>Restart VM</H2>
				<div id="formbox">
					<select name="vm">
					<option value="NULL" selected>--select--</option>
						<?php
							$mysqli = new mysqli("$dbhost", "$dbuser", "$dbpass", "$db");
							/* check connection */
							if ($mysqli->connect_errno) {
								printf("Connect failed: %s\n", $mysqli->connect_error);
								exit();
							}
							$result=$mysqli->query("select server from monitor_services where isvm = 1");
							while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
								echo '<option value="'.$row["server"].'">'.$row["server"].'</option>';
							}
						?>
					</select>
					<input type="submit" name="restart_vm" value="Restart">
				</div>
			</form>
			<form id="restart_file_replication" action="restart-file-replication.php" method="post">
				<H2>Restart ispconfig file replication</H2>
				<div id="formbox">
					<select name="service">
						<option value="all" selected>all</option>
						<?php
							$result=$mysqli->query("select value,label from control_room_menus where menu like 'data-replication'");
							while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
								echo '<option value="'.$row["value"].'">'.$row["label"].'</option>';
							}
						?>
					</select>
					<select name="server">
						<option value="all" selected>all</option>
						<?php
							$result=$mysqli->query("select server from monitor_services where data_replication = 1");
							while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
								echo '<option value="'.$row["server"].'">'.$row["server"].'</option>';
							}
						?>
					</select>
					<input type="submit" name="restart_file_replication" value="Restart">
					<input type="submit" name="restart_file_replication" value="Status">
				</div>
			</form>
			<form id="restart_services" action="restart-services.php" method="post">
				<H2>Restart services</H2>
				<div id="formbox">
					<select name="service">
						<option value="NULL" selected>--select--</option>
						<?php
							$result=$mysqli->query("select value,label from control_room_menus where menu like 'services'");
							while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
								echo '<option value="'.$row["value"].'">'.$row["label"].'</option>';
							}
						?>
					</select>
					<select name="server">
						<option value="NULL" selected>--select--</option>
						<?php
							$result=$mysqli->query("select server from monitor_services");
							while ($row = $result->fetch_array(MYSQLI_ASSOC)) {
								echo '<option value="'.$row["server"].'">'.$row["server"].'</option>';
							}
						?>
					</select>
					<input type="submit" name="restart_services" value="Restart">
			</form>
		</div>
		
	</BODY>
</HTML>