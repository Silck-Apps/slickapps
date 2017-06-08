<?php
/* Params: 1: domain name
			2: api key from bubble
			3: ftpaccess bool
			4: string of tables EG: '"one","two","three"'
*/
$dbserver = "localhost";
$dbroot = "root";
$dbpassword = "R1m@dmin";
$configdir = "/srv/backup/";
$ftpdir = "/srv/ftp/";
$template = $configdir . "scripts/site.config.php.template";

$domain = $argv[1];
$apikey = $argv[2];
$ftpaccess = $argv[3];
$tables = $argv[4];
$dbname = explode(".",$domain)[0];
$configfile = $configdir . $domain . ".config.php";
$homedir = $ftpdir . $dbname; 

// Create SQL queries
$sql_newuser = "CREATE USER '" . $dbname . "'@'localhost' IDENTIFIED by 'new12day';";
$sql_grant = "GRANT ALL PRIVILEGES ON " . $dbname . " . * TO '" . $dbname . "'@'localhost';";
$sql_flush = "FLUSH PRIVILEGES;";
$sql_create = "CREATE DATABASE " . $dbname;


//create config file
if (!file_exists($configfile)) {

$contents = file_get_contents($template);
$contents = str_replace("**DOMAIN**",$domain,$contents);
$contents = str_replace("**APIKEY**",$apikey,$contents);
$contents = str_replace('"**FTPACCESS**"',$ftpaccess,$contents);
$contents = str_replace('"**TABLES**"',$tables,$contents);
file_put_contents($configfile,$contents);
} else {
	echo "Site is alread setup for database backups.\xA";
}

// create backup database

$conn = new mysqli($dbserver, $dbroot, $dbpassword);
// Check SQL connection
if ($conn->connect_error){
	die("Connection failed: " . $conn->connect_error);
} 
$result = $conn->query($sql_create);
if ($result == false) {die("Error creating Database: " . mysqli_error($conn) . "\xA");}
//create backup DB user
$result = $conn->query($sql_newuser);
if ($result == false) {die("Error creating User: " . mysqli_error($conn) . "\xA");}
//assign priviliges to user for DB
$result = $conn->query($sql_grant);
if ($result == false) {die("Error granting permissions: " . mysqli_error($conn) . "\xA");}
$result = $conn->query($sql_flush);
if ($result == false) {die("Error flushing permissions: " . mysqli_error($conn) . "\xA");}

// if ftpaccess is true
if ($ftpaccess == true) {
	// create homedir
	//shell_exec("mkdir " . $homedir);
	// create user account 	, default group ftp, homedir: /srv/ftp/{username} 
	shell_exec("useradd -d " . $ftpdir . $dbname . " -g ftp -m -p new12day " . $dbname);
	// Set owner
	shell_exec("chown -R " . $dbname . ":ftp " . $homedir);
	//	set permissions 554
	shell_exec("chmod -R 554 " . $homedir);
}



?>