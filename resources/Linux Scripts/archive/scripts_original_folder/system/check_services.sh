function check_network_service()
{
service network status
err=$?

if [ $err != 0 ]
then
	for service in $services
	do
		echo "stopping $service"
		service $service stop
	done
	while [ $err != 0 ]
	do
		ifdown eth0; ifup eth0
		service network restart
		err=$?
		echo $err
	done
	for service in $services
	do
		echo "starting $service"
		service $service start
	done
fi
}

case $(hostname) in
	ispcfg01)
	  services='mysql apache2 dovecot postfix pure-ftpd'
	  ;;
	rt01)
	  services='apache2'
	  ;;
	webdev01)
	  services='apache2'
	  ;;
	mysql01)
	  services='mysql'
	  ;;
	esac
	
if [ $(hostname) == 'rt01' ]
	then
	  processes=`pgrep rt-server | sort`
	  kill $processes
	  processes=`pgrep fetchmail | sort`
	  kill $processes
	  check_network_service
	  su helpdesk -c '/srv/www/helpdesk/sbin/rt-server &'
	  su helpdesk -c 'fetchmail -f /etc/fetchmailrc -d 300 &'
	else
	  check_network_service
	fi