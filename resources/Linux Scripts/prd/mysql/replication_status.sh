#dbuser=bennettw
#dbpass=sambo174
dbrepeluser=replication
dbrepelpass=new12day
mysqlserver="ispcfg01.skdk.internal"
slaveserver="ispcfg02.skdk.internal"
otherdbs="dbispconfig_old scripts_data"
tmpfile="/srv/resources/tmp/databases.sql"
faillog="/srv/resources/log/fail/mysql.log"
dumpdirs=0
dumprelaylogs=0
dumplogs=0
servers="$mysqlserver $slaveserver"
#dbuser='scripts_data'
#dbpass='new12day'
#dbserver='mysql.skdk.internal'
dbport=3306
db='scripts_data'
service="mysql_replication"

#mysqlstring="mysql -u$dbuser -p$dbpass -h$dbserver -P$dbport $db -Bse"
mysqlstring="mysql --login-path=scripts $db -Bse"

servers=$($mysqlstring "select server from monitor_services where $service is true") 
runas="normal"
while getopts "sf" OPTION 
do
	case $OPTION in
	s)
	  runas="script"
	  ;;
	f)
	  runas="faillog"
	  ;;
	esac
done

function echo_results {
  echo "Server: $server"
  echo "Slave State: '$slavestate'"
  echo "  IO Thread is $IOstatus"
  echo "  SQL Thread is $SQLstatus"
}

function script_output {

if [ "$IOstatus" == "Running" ] 
then
  msg="Running"
  status=1
 else
  msg="Not Running"
  status=0
 fi
 
 servicename="mysql_IO"
 $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$servicename', '$status', '$msg');" 
 
 if [ "$SQLstatus" == "Running" ]
 then
   msg="Running"
   status=1
 else
   msg="Not Running"
   status=0
 fi
 
 servicename="mysql_SQL"
 $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$servicename', '$status', '$msg');" 


}

function faillog {
	timestamp="$(date +%d/%m/%Y) -- $(date +%H:%M:%S)"
	if [ "$IOstatus" != "Running" ] 
	then
		echo "$timestamp -- server: $server -- IO Thread stopped" &>> $faillog
	fi
	if [ "$SQLstatus" != "Running" ] 
	then
		echo "$timestamp -- server: $server -- SQL Thread stopped" &>> $faillog
	fi
}

for server in $servers
do
  IOstatus=$(mysql --login-path=scripts_no_host -h$server -e 'show slave status\G' | grep Slave_IO_Running | tr -d ":" | sed -e 's/\<Slave_IO_Running\>//g')
  SQLstatus=$(mysql --login-path=scripts_no_host -h$server -e 'show slave status\G' | grep Slave_SQL_Running | tr -d ":" | sed -e 's/\<Slave_SQL_Running\>//g')
  slavestate=$(mysql --login-path=scripts_no_host -h$server -e 'show slave status\G' | grep Slave_IO_State | tr -d ":" | sed -e 's/\<Slave_IO_State\>//g' | sed -e 's/^ *//g' -e 's/ *$//g')
if [ "$(echo $IOstatus | awk {'print $1'})" == "Yes" ]
then
  IOstatus="Running"
else
  IOstatus="Not Running"
fi

if [ "$(echo $SQLstatus | awk {'print $1'})" == "Yes" ]
then
  SQLstatus="Running"
else
  SQLstatus="Not Running"
fi

	case $runas in
		"script")
			script_output
			;;
		"faillog")
			faillog
			;;
		*)
			echo_results
			;;
	esac
done

