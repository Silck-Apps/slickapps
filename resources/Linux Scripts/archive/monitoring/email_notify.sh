dbuser='scripts_data'
sshuser="vboxdrv"
mailuser="wayne.bennett@i-fix.com.au"
dbpass='new12day'
mailpass="sambo174"
datadir='/srv/resources/scripts/monitoring/data'
dbserver='mysql.skdk.internal'
dbport=3306
db='scripts_data'
excludevms="ispcfg_dev"
db_data="/tmp/db_data.csv"
tmpdir="/srv/resources/tmp"

emailsubject="Monitoring Notification"
emailto="wayne.bennett@i-fix.com.au"
emailfrom="webmaster@i-fix.com.au"


webservers="ispcfg01 ispcfg02"
vmservers="vmserv01 vmserv02"
netservers="util01 util02"
dmzservers="dmz01 dmz02"
proxyservers="proxy01 proxy02"
otherservers="fs01 rt01"

allservers="$webservers $vmservers $netservers $dmzservers $proxyservers $otherservers"

function test_vms {
  for server in $vmservers
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
  echo $vmstate > $datadir/$vm.state
  done 
done
}

test_dovecot() {
servers=$1
sqlhost=$(mysql -u$dbuser -p$dbpass -h$dbserver -P$dbport $db -Bse "show variables like 'hostname'; select server,service,port,protocol from services where service = 'dovecot' INTO OUTFILE '$db_data' FIELDS TERMINATED BY ' ' ENCLOSED BY '' LINES TERMINATED BY '\n';" | awk '{print $2}')
ssh $sqlhost "cp $db_data $tmpdir"
  for server in $servers
  do 
    ssh $server "if [ -e $db_data ]; then rm $db_data; fi"

while read line
do 
 if [ "$(echo $line | awk '{print $1}')" == "$server" ]
 then
 server=$(echo $line | awk '{print $1}')
 service=$(echo $line | awk '{print $2}')
 port=$(echo $line | awk '{print $3}')
 protocol=$(echo $line | awk '{print $4}')
case $protocol in
  imap)
     conn_data=$({ echo "a1 LOGIN $mailuser $mailpass"; echo "a5 LOGOUT"; sleep 5; } | telnet $server $port 2> /dev/null)
     if [ `echo $conn_data | grep -c "OK"` -eq 0 ]
     then
      imap_state='down'
     else
      imap_state='up'
     fi
    ;;
  pop3)
    conn_data=$({ echo "user $mailuser"; echo "pass $mailpass"; sleep 5; } | telnet $server $port 2> /dev/null)
    if [ `echo $conn_data | grep -c "OK"` -eq 0 ]
    then
     pop_state='down'
    else
     pop_state='up'
    fi
    ;;
esac

if [ $imap_state == 'up' ] && [ $pop_state == 'up' ]
then
  echo "Running" > $datadir/$server.dovecot.service
else
   echo "Not Running" > $datadir/$server.dovecot.service
fi
fi
done < "$tmpdir/db_data.csv"
done
}

function test_postfix {
port=25
servers=$1
for server in $servers
do
  conn_data=$({ echo "HELO verify-email.org"; echo "MAIL FROM: <check@verify-email.org>"; echo "RCPT TO: <wayne.bennett@i-fix.com.au>"; sleep 5; } | telnet $server $port 2> /dev/null)

  if [ `echo $conn_data | grep -c "Ok"` -eq 0 ]
then
  echo "Not Running" > $datadir/$server.postfix.service
else
   echo "Running" > $datadir/$server.postfix.service
fi

done
}

function test_apache2 {
 port=80
 servers=$1
 for server in $servers
 do
  conn_data=$({ echo "bye"; sleep 5; } | telnet $server $port 2> /dev/null)
  if [ `echo $conn_data | awk {'print $3'}` == "Connected" ]
  then
   echo "Running" > $datadir/$server.apache2.service
  else
   echo "Not Running" > $datadir/$server.apache2.service
  fi
 done
}

function test_pureftpd {
 port=21
 servers=$1
 for server in $servers
 do
  conn_data=$({ echo "quit"; sleep 5; } | telnet $server $port 2> /dev/null)
  if [ `echo $conn_data | awk {'print $3'}` == "Connected" ]
  then
   echo "Running" > $datadir/$server.pure-ftpd.service
  else
   echo "Not Running" > $datadir/$server.pure-ftpd.service
  fi
 done
}

function test_mysql {
  servers=$1
  for server in $servers
  do
    conn_data=$(mysql -h$server -u$dbuser -p$dbpass -e "show databases;" | grep $db)
    if [ $conn_data == $db ]
    then
      echo "Running" > $datadir/$server.mysql.service
    else
      echo "Not Running" > $datadir/$server.mysql.service
    fi
  done
}

function test_DNS {
  for server in $netservers
  do
    conn_data=$(echo $(dig @$server skdk.internal | awk {'print $1'}) | awk {'print $12'})
    if [ $conn_data == "skdk.internal." ] 
    then
      echo "Running" > $datadir/$server.named.service
    else
      echo "Not Running" > $datadir/$server.named.service
    fi
  done
}
function test_DHCP {
  server="ispcfg01"
  primaryip="10.11.1.1"
  secondaryip="10.11.2.1"
  ip=$(echo $(ssh $server 'ifconfig eth0' | awk {'print $2'}) | awk {'print $2'} | sed 's/addr://g')
  dhcpip=$(echo $(ifconfig eth0 | awk {'print $2'}) | awk {'print $2'} | sed 's/addr://g')
  macid=$(echo $(ssh $server 'ifconfig eth0' | awk {'print $5'}) | awk {'print $1'})
  conn_data=$(ssh $server "dhcping -c $ip -s $dhcpip -h $macid")
  successmsg="Got answer from: $dhcpip"

  if [ "$conn_data" == "$successmsg" ]
  then
   echo "Running on primary" > $datadir/dhcp.status
  else
    conn_data=$(echo $(ssh ispcfg01 'dhcpcd-test eth0' | awk {'print $6'}) | awk {'print $6'})
    case $conn_data in
      $primaryip)
        echo "Running on primary" &> $datadir/dhcp.status
       ;;
      $secondaryip)
        echo "Running on secondary" &> $datadir/dhcp.status
       ;;
      *)
       echo "Not Running" &> $datadir/dhcp.status
       ;;

    esac
  fi
}

function test_ntp {
  for server in $allservers
  do
    ssh $server 'ntptime > /dev/null'
    exitcode=$(echo $?)
    case $exitcode in
      0)
       echo "Syncronised" > $datadir/$server.ntp.service
      ;;
      1)
       echo "Out of Sync" > $datadir/$server.ntp.service
      ;;
      2)
       echo "Not Running" > $datadir/$server.ntp.service
      ;;
    esac
  done
}

function test_rt {
  services="rt-server fetchmail"
  for service in $services
  do
    conn_data=$(ssh rt01 "ps -C $service --noheaders" | awk {'print $1'})
    if [ -z "$conn_data" ]
    then
      echo "Running" > $datadir/rt01.$service.service
    else
      echo "Not Running" > $datadir/rt01.$service.service
    fi
  done
  test_apache2 rt01
}

function evaluate_results {
sendmail="false"
cd $datadir
if [ -e email.message ]
then
rm email.message
fi
sections="dhcp ntp vms services replication"
for section in $sections
do

  case $section in
    "dhcp")
      lscmd="dhcp.status"
      ifnotstatus="Running on primary"
      titleline="DHCP not on primary"
      ;;
    "ntp")
      lscmd="*.ntp.*"
      ifnotstatus="Syncronised"
      titleline="NTP Not Syncronised"
      ;;
    "vms")
      lscmd="*.state"
      ifnotstatus="running"
      titleline="VMs Not Running"
      ;;
    "services")
      lscmd="*.apache2.* *.dovecot.* *.postfix.* *.pure-ftpd.* *.mysql.*"
      ifnotstatus="Running"
      titleline="Service(s) Down"
      ;;
    "replication")
      lscmd="ispcfg*.status"
      ifnotstatus="Running"
      titleline="Replication Stopped"
      ;;    
  esac

files=$(ls $lscmd)
i=0
for file in $files
do
  server=$(echo $file | tr '.' ' ' | awk {'print $1'})
  service=$(echo $file | tr '.' ' ' | awk {'print $2'})
  statustext=$(cat $file)
  if [ "$statustext" != "$ifnotstatus" ]
  then
    sendmail="true"
    if [ i == 0 ]
    then
      echo $titleline >> email.message
    fi
      echo "Server: $server -- Service: $service -- Status: $statustext" >> email.message
  fi
i=$(($i+1))
done
done
}

function send_email {
cd $datadir
echo "To:$emailto" > email.smtp
echo "From:$emailfrom" >> email.smtp
echo "Subject:$emailsubject" >> email.smtp
echo "" >> email.smtp
cat email.message >> email.smtp
ssmtp $emailto < email.smtp
rm email.smtp
mv email.message last.email.message
}

function send_summary {
echo "Send Summary"
}

function email_results {
cd $datadir
if [ "$sendmail" == "true" ]
then
  acknowledged=$(cat email.acknowledged)
  if [ "$acknowledged" == "yes" ]
  then
    diff=$(comm -3 email.message last.email.message)
    if [ -z "$diff" ]
    then
       send_summary
    else
       echo "" >> email.message
       echo "email is being sent because a different issue was found......." >> email.message
       send_email
    fi
  else
    send_email
  fi
else
  send_summary
fi
}

function test_replication {
/srv/resources/scripts/ispconfig/data-replication/replication-status.sh "$datadir"
/srv/resources/scripts/mysql/replication_status.sh "$datadir"
}

function test_haproxy {
test_postfix "$dmzservers"
test_dovecot "$dmzservers"
test_apache2 "$dmzservers"
}

function test_ftpproxy {
test_pureftpd "$dmzservers"
}

function test_mysqlproxy {
test_mysql "$proxyservers"
}

function test_proxies {
test_haproxy
test_ftpproxy
test_mysqlproxy
}


test_services() {
test_dovecot "$webservers"
test_postfix "$webservers"
test_apache2 "$webservers"
test_pureftpd "$webservers"
test_mysql "$webservers"
test_DNS
test_DHCP
test_ntp
}

while [ 0 == 0 ]
do
test_vms
test_services
test_replication
test_proxies
test_rt
evaluate_results
email_results
sleep 300
done
