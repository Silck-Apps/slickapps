<?php
date_default_timezone_set("Australia/Brisbane");
$servername = "localhost";
$password = "new12day";
$num = 200; //VARCHAR number of characters
$log_sql = "-sql.log";
$log_excluded = "-excluded-fields.log";
$log_errors = "-errors.log";
$cURLhead = array(
	'Authorization: Bearer **REPLACE**',
	'Content-type: application/json'
	);
$urlprefix = "https://**DOMAIN**/api/1.0/obj/";

/*
Site config files need the following variables:
$domain = "**complete domain name here**";
$dbname = explode(".",$domain)[0]
$username = $dbname
$tables = array(** Add table names here **);
$log_sql = $domain . $log_sql
$log_excluded = $domain . $log_excluded
$log_errors = $domain . $log_errors
$apiKey = "088516e347cd8c69ebce0e5d0f4f193a"
$cURLhead = str_replace("**REPLACE**",$apiKey,$cURLhead['Authorization'])
$urlprefix = str_replace("**DOMAIN**",$domain,$urlprefix)
$ftpaccess = boolean false if not paying for FTP access to backup

In PHPmyAdmin:

Create database
create user and grant access for localhost
*/
?>