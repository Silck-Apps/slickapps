OPTIND=1

usage()
{
cat<<EOF
Usage: $0 options

This script starts stops and restarts request tracker

REQUIRED PARAMETERS:
  -a Action. Stop, start or restart services

OPTIONAL PARAMETERS
  -h show help
  -m Delete Mason data. Action must be start or restart

EOF
}

#services="vmail www"
servers="ispcfg01 ispcfg02"
delmason="no"
scriptdir="/srv/resources/scripts/requesttracker"
masondirs="/srv/www/helpdesk/var/mason_data/obj /opt/rt4/var/mason_data/obj"
#logdir="/var/log/ispconfig/data-replication"
#piddir="/etc/ispconfig-data-replication"

while getopts "a:hm" OPTION
do
        case $OPTION in
        h)
         usage
         exit
         ;;
        m)
	 delmason="yes"
	 ;;
	a) 
	 action=$OPTARG
         ;;
	?)
         usage
         exit
         ;;
        esac
done


start(){

#    pids=$(ps -C rt-server)
    processes=$(ps --no-headers -C "rt-server" | awk '{print $1}')

#PID=$(cat program.pid)
#if [ -e /proc/${PID} -a /proc/${PID}/exe -ef /usr/bin/program ]; then
#echo "Still running"
#fi


    if [ -z "$processes" ]
    then
    if [ $delmason == "yes" ]
    then
      for dir in $masondirs
      do
        echo "removing cache dir $dir......"
        rm -fr $dir
      done
    fi    
    echo "starting apache on $HOSTNAME...."
    /etc/init.d/apache2 start
    echo "Starting rt-server......"
    su helpdesk -c '/srv/www/helpdesk/sbin/rt-server &'
    echo "Starting fetchmail service......."
    su helpdesk -c 'fetchmail --sslproto ssl23 -f /etc/fetchmailrc -d 10'
#    sleep 5
    for server in $servers
    do
      echo "restarting apache on $server....."
      ssh $server '/etc/init.d/apache2 restart'
    done
    else
      echo "RT Server already running. try restart......"

    fi

}

stop(){
    echo "Killing fetchmail....."
    killall fetchmail
    echo "killing rt-server processes....."
    killall rt-server
    echo "Stopping apache on $HOSTNAME......."
    /etc/init.d/apache2 stop 
}

if [ $delmason == "yes" -a $action == "stop" ]
then
  usage
  echo "Action '$action' is not allowed with -m switch. Try again"
  exit 1
fi
case "$action" in
  start)
    start
	exit
    ;;
  stop)
    stop
	exit
    ;;
  restart)
    stop
    sleep 3
    start
	exit
    ;;
  killall)
    stop
	exit
    ;;
  *)usage
    exit 1
esac
exit


