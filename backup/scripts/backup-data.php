<?php
$backupdir = "/srv/backup/";
Include $backupdir . "master.config.php"; 
Include $backupdir . $argv[1] . ".config.php";
// ***************************Variables *****************
$dbname = explode(".",$domain)[0];
$username = $dbname;
$log_sql = $backupdir . "logs/" . $domain . $log_sql;
$log_excluded = $backupdir . "logs/" . $domain . $log_excluded;
$log_errors = $backupdir . "logs/" . $domain . $log_errors;
$cURLhead = str_replace("**REPLACE**",$apiKey,$cURLhead[0]);
$urlprefix = str_replace("**DOMAIN**",$domain,$urlprefix);
// ******************* Error Handler ***********************
function customError($errno, $errstr, $table, $log_errors) {
	if ($table != __FILE__) {
		file_put_contents($log_errors, date('d-m-Y:H:i:s') . " - Table: " . $table . "\xA",FILE_APPEND);
		file_put_contents($log_errors, date('d-m-Y:H:i:s') . " - Exception: [$errno] $errstr\xA",FILE_APPEND);
	} else {
		$log_errors = "/srv/backup/logs/general-errors.log";
		file_put_contents($log_errors, date('d-m-Y:H:i:s') . " - Exception: [$errno] $errstr\xA",FILE_APPEND);
	}
}
set_error_handler("customError");
file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - ***** Backup run started *******\xA",FILE_APPEND);
file_put_contents($log_excluded,date('d-m-Y:H:i:s') . " - ***** Backup run started *******\xA",FILE_APPEND);
file_put_contents($log_errors,date('d-m-Y:H:i:s') . " - ***** Backup run started *******\xA",FILE_APPEND);



// Create SQL connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check SQL connection
if ($conn->connect_error){
	die("Connection failed: " . $conn->connect_error);
} 


foreach ($tables as $table) {
$conn->query("DROP TABLE " . strtolower($table) . ";");

// Create insert query prefix
$sql_create = "CREATE TABLE " . strtolower($table) . " (";
$sql_insert = 'INSERT IGNORE INTO ' . strtolower($table) . 'SET ';
// Set Unique field
Switch (true) {
	case stristr($table,"user"): 
		$unique = "email";
		break;
	default:
		$unique = NULL;
		break;
}
// Set API URL
$url = $urlprefix . $table;
$cURL = curl_init();
curl_setopt($cURL, CURLOPT_URL, $url);
curl_setopt($cURL, CURLOPT_HTTPGET, true);
curl_setopt($cURL, CURLOPT_RETURNTRANSFER, true);
curl_setopt($cURL, CURLOPT_HTTPHEADER, $cURLhead);
$result = curl_exec($cURL);
curl_close($cURL);
$json = json_decode($result, true);
$records = $json['response']['results'];
$data = $json['response']['results'][0];

if (gettype($data) != "NULL") {
	$i = 0;

	foreach ($data as $field) {
		Switch (true) {
			case stristr(gettype($field),"string"):
				$type = "VARCHAR($num)";
				break;
			case stristr(gettype($field),"integer"):
				if (stristr(array_keys($data)[$i],"Date") == true or stristr(array_keys($data)[$i],"custom") == true) {
					$type = "BIGINT";
				} else {
					$type = "INT";
				}
				break;
			case stristr(gettype($field),"boolean"):
				$type = "BOOLEAN";
				break;
			default:
				$type = gettype($field);
				break;
		}
		if (stristr($unique,array_keys($data)[$i]) == true) {
			$type = $type . " UNIQUE";
		}
		if (stristr(array_keys($data)[$i],"authentication") == true) {
			$fieldname = "email";
			$type = "VARCHAR($num)";
		} else {
			$fieldname = strtolower(str_replace(" ","_",array_keys($data)[$i]));
		}
	
		if (stristr($type,"array") != true) {
			if ($i != 0) {
				$sql_create = $sql_create . ", " . $fieldname . " " . $type ;
			} else {
				$sql_create = $sql_create . $fieldname . " " . $type ;
			}
			$i++;
		} else {
			file_put_contents($log_excluded,date('d-m-Y:H:i:s') . " - Field " . array_keys($data)[$i] . " is a $type. Excluded.....\xA",FILE_APPEND);
		}
	}

$sql_create = $sql_create . ");";
if (stristr($sql_create,"CREATE TABLE $table ()") != true) {
$conn->query($sql_create);
file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - " . $sql_create . "\xA",FILE_APPEND);
}
$z = 0;
foreach ($records as $rec) {
$i = 0;
$qry = "INSERT IGNORE INTO " . strtolower($table) . " SET ";
foreach ($rec as $field) {
$fieldname = array_keys($rec)[$i];
if (stristr($fieldname,"address_geographic_address") == true) {
	$field = explode("/",$rec['address_geographic_address'])[1];
}
if (stristr($fieldname,"authentication") == true) {
	$field = $rec['authentication']['email']['email'];
}

if (stristr(gettype($field),"array") != true) {
	$fieldname = str_replace(" ","_",strtolower(array_keys($rec)[$i]));
	if ($i != 0) {
		$qry = $qry . '", ' . $fieldname . '="' . $field;
		} else {
			$qry = $qry . $fieldname . '="' . $field;
		}

}	

$i++;
}

$z++;
$qry = str_replace("authentication","email",$qry) . '";';
$qryresult = $conn->query($qry);
file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - " . $qry . "\xA",FILE_APPEND);
if ($qryresult == false) {
Switch (mysqli_errno($conn)) {
	case 1054:
		$Missingfield = explode("'",mysqli_error($conn))[1];
		$qry_alter = "ALTER TABLE " . strtolower($table) . " ADD " . $Missingfield . " " . str_replace(" UNIQUE","",$type) . ";";
		$qryresult = $conn->query($qry_alter);
		file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - " . $qry_alter . "\xA",FILE_APPEND);
		$conn->query($qry);
		file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - " . $qry . "\xA",FILE_APPEND);
		break;
}

		}
	}

} else {
	file_put_contents($log_errors,date('d-m-Y:H:i:s') . " - Curl returned null for table $table.\xA",FILE_APPEND);
}
}
$conn->close();
if ($ftpaccess == true) {
	shell_exec("mysqldump --user=" . $username . " --password=" . $password . " " . $dbname . " >> /srv/ftp/" . $dbname . "/" . date('Y-m-d') . "_" . $domain . "_data.sql");
	shell_exec("chown vftp:ftp /srv/ftp/" . $dbname . "/" . date('Y-m-d') . "_" . $domain . "_data.sql");
}


file_put_contents($log_sql,date('d-m-Y:H:i:s') . " - ***** Backup run Completed *******\xA\xA",FILE_APPEND);
file_put_contents($log_excluded,date('d-m-Y:H:i:s') . " - ***** Backup run Completed *******\xA\xA",FILE_APPEND);
file_put_contents($log_errors,date('d-m-Y:H:i:s') . " - ***** Backup run Completed *******\xA\xA",FILE_APPEND);
?>
