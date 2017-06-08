#dbuser='scripts_data'
#bpass='new12day'
#dbserver='mysql.skdk.internal'
#dbport=3306
db='scripts_data'

service="data_replication"

#mysqlstring="mysql -u$dbuser -p$dbpass -h$dbserver -P$dbport $db -Bse"
mysqlstring="mysql --login-path=scripts $db -Bse"

servers=$($mysqlstring "select server from monitor_services where $service is true")

services='vmail www'
piddir='/etc/ispconfig-data-replication'
script=0

while getopts "s" OPTION 
do
	case $OPTION in
	s)
	  script=1
	  ;;
	esac
done

function echo_result {
for server in $1
do
echo "Server: $server"
  for service in $services
  do
    pid=$(ssh $server "cat $piddir/$service.pid")
    process=$(ssh $server "ps --no-headers -p $pid" | awk '{print $1}')
    if [ -z "$process" ]
    then
      process="none"
    fi
    case $process in
      $pid) echo "   $service replication is OK. process ID: $pid"
      ;;
      none) echo "   $service not running. proocess ID $pid not found"
      ;;
      *) echo "   Something's up with the $service service. Have a look yourself! Look for these processes: $process" 
      ;;

    esac
  done

done
}

function script_output {

for server in $servers
do
  for service in $services
  do
    pid=$(ssh $server "cat $piddir/$service.pid")
    process=$(ssh $server "ps --no-headers -p $pid" | awk '{print $1}')
	servicename=$(echo $service"_rep")	
    if [ -z "$process" ]
    then
      process="none"
    fi
    case $process in
      $pid)
	  msg="Running"
	  status=1
      ;;
      none)
	  msg="Not found"
	  status=0
      ;;
      *)
	  msg="error"
	  status=0
      ;;

    esac
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$servicename', '$status', '$msg');" 
  done
done


}

if [ $script == 1 ]
then
  script_output
else
  echo_result "$servers"
fi
