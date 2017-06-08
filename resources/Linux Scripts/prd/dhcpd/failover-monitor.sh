#cron.daily  run-backup -> /srv/resources/scripts/backup/run-backup.sh
#cron.weekly check_updates -> /srv/resources/scripts/updates/zypper_check_new.sh	
#cron.hourly  update-svn -> /srv/resources/scripts/subversion/cron.sh


#fail over monitoring



#fail over dhcp

source "/srv/resources/scripts/functions.sh"

server="util01"
ip=$(getip $server $(getinterface $server))
interface=$(getinterface localhost)
while [ 0 == 0 ]
do
result=$(echo $(dhcpcd-test $interface | awk {'print $6'}) | awk {'print $6'})
if [ "$result" == "$ip" ]
then
  /etc/init.d/dhcpd status > /dev/null
  status=$?
  if [ $status == 0 ]
  then 
    /etc/init.d/dhcpd stop > /dev/null
  fi
else
  /etc/init.d/dhcpd status > /dev/null
  status=$?
  if [ $status != 0 ]
  then 
   /etc/init.d/dhcpd restart
  fi
fi
sleep 300
done
