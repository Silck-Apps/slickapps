#dbuser='scripts_data'
sshuser="vboxdrv"
mailuser="wayne.bennett@i-fix.com.au"
#dbpass='new12day'
mailpass="sambo174"
dbserver='mysql.skdk.internal'
dbport=3306
db='scripts_data'
excludevms="ispcfg_dev"

checkinterval=300 # time between checks in seconds
emailsubject="Monitoring Notification"
emailto="wayne.bennett@i-fix.com.au"
emailfrom="webmaster@i-fix.com.au"

#mysqlstring="mysql -u$dbuser -p$dbpass -h$dbserver -P$dbport $db -Bse"
mysqlstring="mysql --login-path=scripts $db -Bse"

source "/srv/resources/scripts/functions.sh"

function test_servers {
	servers=$($mysqlstring "select server from monitor_services")
	test_connection "$servers"
	deadservers=${dead[@]}
}

function ignore_dead_servers {
	for server in $deadservers
	do
		servers=$(echo $servers | sed "s/$server//g")
	done
}

function test_ntp {
  service="ntp"
  servers=$($mysqlstring "select server from monitor_services")
  ignore_dead_servers
  for server in $servers
  do
    ssh $server 'ntptime > /dev/null'
    exitcode=$(echo $?)
    case $exitcode in
      0)
       msg="Running"
	   status=1
      ;;
      1)
       msg="Out of Sync"
	   status=0
      ;;
      2)
       msg="Not Running"
	   status=0
      ;;
    esac
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
  done
}

function test_vms {
  service="vm"
  servers=$($mysqlstring "select server from monitor_services where $service is true")
  ignore_dead_servers
  for server in $servers
  do

vms=$(ssh $sshuser@$server 'vboxmanage list vms' | awk '{print $1}' | tr -d '"')
for vm in $excludevms
do
  vms=$(echo $vms | sed "s/$vm//g")
  if [ -e $datadir/$vm.state ]
  then
    rm $datadir/$vm.state
  fi
done

  for vm in $vms
  do
    vmstate=$(ssh $sshuser@$server "/usr/bin/vboxmanage showvminfo $vm --machinereadable" | grep "VMState=")
    vmstate=$(echo "${vmstate#*=}" | tr -d '"')
  case $vmstate in
    "running")
	  msg="Running"
	  status=1
	  ;;
	*)
	  msg=$vmstate
	  status=0
	  ;;
	esac
#  echo $vmstate > $datadir/$vm.state
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$vm', '$service', '$status', '$msg');"
  done 
done
}

test_dovecot() {
service="dovecot"
servers=$($mysqlstring "select server from monitor_services where $service is true")
protocols="imap pop3"
imapport="143"
popport="110"
ignore_dead_servers
for server in $servers
do
conn_data=$({ echo "a1 LOGIN $mailuser $mailpass"; echo "a5 LOGOUT"; sleep 5; } | telnet $server $imapport 2> /dev/null)
    if [ `echo $conn_data | grep -c "OK"` -eq 0 ]
    then
		imap_state='down'
    else
		imap_state='up'
    fi
conn_data=$({ echo "user $mailuser"; echo "pass $mailpass"; sleep 5; } | telnet $server $popport 2> /dev/null)
    if [ `echo $conn_data | grep -c "OK"` -eq 0 ]
    then
     pop_state='down'
    else
     pop_state='up'
    fi
if [ $imap_state == 'up' ] && [ $pop_state == 'up' ]
then
  msg="Running"
  status=1
else
   msg="Not Running"
   status=0
fi
$mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
done
}

function test_postfix {
port=25
service="postfix"
servers=$($mysqlstring "select server from monitor_services where $service is true")
ignore_dead_servers
for server in $servers
do
  conn_data=$({ echo "HELO verify-email.org"; echo "MAIL FROM: <check@verify-email.org>"; echo "RCPT TO: <wayne.bennett@i-fix.com.au>"; sleep 5; } | telnet $server $port 2> /dev/null)

  if [ `echo $conn_data | grep -c "Ok"` -eq 0 ]
then
  msg="Not Running"
  status=0
else
   msg="Running"
   status=1
fi
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
done
}

function test_apache2 {
 service="apache2"
 servers=$($mysqlstring "select server from monitor_services where $service is true")
 ignore_dead_servers
 for server in $servers
 do
  if [ $server == "fs01" ]
  then
    port="9090"
  else
    port="80"
  fi
  conn_data=$({ echo "bye"; sleep 5; } | telnet $server $port 2> /dev/null)
  if [ `echo $conn_data | awk {'print $3'}` == "Connected" ]
  then
   msg="Running"
   status=1
  else
   msg="Not Running"
   status=0
  fi
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
 done
}

function test_pureftpd {
 port=21
 service="ftp"
 servers=$($mysqlstring "select server from monitor_services where $service is true")
 ignore_dead_servers
 for server in $servers
 do
  conn_data=$({ echo "quit"; sleep 5; } | telnet $server $port 2> /dev/null)
  if [ `echo $conn_data | awk {'print $3'}` == "Connected" ]
  then
   msg="Running"
   status=1
  else
   msg="Not Running"
   status=0
  fi
 $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
 done
}

function test_mysql {
 service="mysql"
 servers=$($mysqlstring "select server from monitor_services where $service is true")
 ignore_dead_servers

  for server in $servers
  do
    conn_data=$(mysql --login-path=scripts_no_host -h$server -e "show databases;" | grep $db)
    if [ $conn_data == $db ]
    then
      msg="Running"
	  status=1
    else
      msg="Not Running"
	  status=0
    fi
  $mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
  done
}

function test_DNS {
 service="named"
 servers=$($mysqlstring "select server from monitor_services where $service is true")
 ignore_dead_servers
  for server in $servers
  do
    conn_data=$(echo $(dig @$server skdk.internal | awk {'print $1'}) | awk {'print $12'})
    if [ $conn_data == "skdk.internal." ] 
    then
      msg="Running"
	  status=1
    else
      msg="Not Running"
	  status=0
    fi
$mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
  done
}

function test_DHCP {
  service="dhcpd"
  source "/srv/resources/scripts/functions.sh"
  servers=$($mysqlstring "select server from monitor_services where $service is true")
  ignore_dead_servers
  testserver=$(echo $($mysqlstring "select server from monitor_services") | sed "s/util01//g" | sed "s/util02//g" | awk {'print $1'})
 for server in $servers
  do

  ip=$(getip $testserver $(getinterface $testserver))  
  dhcpip=$(getip $server $(getinterface $server))  
  macid=$(getinterfacemac $testserver $(getinterface $testserver))  
  
  conn_data=$(ssh $testserver "dhcping -c $ip -s $dhcpip -h $macid")
  successmsg="Got answer from: $dhcpip"

  case $server in
    "util01")
	  if [ "$conn_data" == "$successmsg" ]
	  then
	    msg="Running"
	    status=1
	  else
	    msg="Not Running"
		status=0
      fi
	;;
	"util02")
	  query=$($mysqlstring "select status from monitor_status where server = 'util01' and service = 'dhcpd'";)
	  if [ "$conn_data" == "$successmsg" ]
	  then
	    if [ $query == 1 ]
		then
		  msg="Duplicate Running"
		  status=0
		else
		  msg="Running"
		  status=0
		fi
      else
	    if [ $query == 1 ]
		then
		  msg="Not Running"
		  status=1
		else
		  msg="Not Running"
		  status=0
		fi
	  fi
	  
	;;
  esac
$mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');"
done
}

function test_rt {
	service="rt"
	server=$($mysqlstring "select server from monitor_services where $service is true")
	services="rt-server fetchmail"
	echo $deadservers | grep -q "$service"
	result=$?
	if [ $result -eq 1 ]
	then
		for service in $services
		do
		conn_data=$(ssh $server "ps -C $service --noheaders" | awk {'print $1'})
			if [ ! -z "$conn_data" ]
			then
				msg="Running"
				status=1
			else
				msg="Not Running"
				status=0
			fi
			$mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');" 
		done
	fi
}

function test_replication {
/srv/resources/scripts/ispconfig/data-replication/replication-status.sh -s
/srv/resources/scripts/mysql/replication_status.sh -s
}

function test_dhcpmonitor {
	service="dhcp_monitor"
	server=$($mysqlstring "select server from monitor_services where $service is true")
	conn_data=$(ssh $server '/srv/resources/scripts/dhcpd/control-failover-monitor.sh -a status')
	echo $conn_data | grep -q "Monitor is OK"
	result=$?
	if [ $result -eq 0 ]
	then
		msg="Running"
		status=1
	else
		msg="Not Running"
		status=0
	fi
	$mysqlstring "INSERT INTO scripts_data.monitor_status (server, service, status, message) VALUES ('$server', '$service', '$status', '$msg');" 
}

while [ 0 == 0 ]
do
    conn_data=$(mysql --login-path=scripts -e "show databases;" | grep $db)
    if [ "$conn_data" != "$db" ]
	then
		/srv/resources/scripts/monitoring/evaluate_and_notify.sh -f
	else
		$mysqlstring "truncate monitor_status"
		test_servers
		test_ntp
		test_vms
		test_dovecot
		test_postfix
		test_apache2
		test_pureftpd
		test_mysql
		test_DNSsh 
		test_DHCP
		test_dhcpmonitor
		test_rt
		test_replication
		checkstatus=$($mysqlstring "select status from scripts_data.monitor_status where status = 0")
		echo $deadservers
		if [ "$checkstatus" != "" ] || [ "$deadservers" != "" ]
		then
			/srv/resources/scripts/monitoring/evaluate_and_notify.sh -d "$deadservers"
		fi
	fi
	sleep $checkinterval
done
