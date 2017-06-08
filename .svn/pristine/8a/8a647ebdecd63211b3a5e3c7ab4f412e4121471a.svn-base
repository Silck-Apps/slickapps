
OPTIND=1

usage()
{
cat<<EOF
Usage: $0 options

This script starts stops and restarts monitoring services

REQUIRED PARAMETERS:
  -a Action. Stop, start, restart services or show current Status

OPTIONAL PARAMETERS
  -h show help

EOF
}



scriptdir="/srv/resources/scripts/dhcpd"
piddir="/etc/dhcpd"
script="failover-monitor.sh"



while getopts "a:h" OPTION
do
        case $OPTION in
        h)
         usage
         exit
         ;;
        a)
         action=$OPTARG
         ;;
        *)
         usage
         exit
         ;;
        esac
done

startservice () {
$scriptdir/$script &>> /dev/null &
echo $! > $piddir/monitoring.pid
}



start(){

    pid=$(cat $piddir/monitoring.pid)
    process=$(ps --no-headers -p $pid | awk '{print $1}')

    if [ -z $process ]
    then

    echo "Starting up monitor......"
   startservice

    else
      echo "monitor service already running. Process ID: $process....... This instance was not started......."

    fi

}



stop(){
    echo "Stopping monitor..."
    pid=$(cat $piddir/monitoring.pid)
    ppid=$(ps --no-headers --ppid $pid | awk '{print $1}')
    process=$(ps --no-headers -p $pid | awk '{print $1}')
    echo "     Stopping processes $pid $ppid......."
    if [ ! -z $process ]
    then
      kill $pid $ppid
    fi
}

status() {
    pid=$(cat $piddir/monitoring.pid)
    process=$(ps --no-headers -p $pid | awk '{print $1}')

    if [ -z $process ]
    then
      echo "Process ID $pid not found. Monitor is not running"
    else
      echo "Monitor is OK. Process ID $pid found."
    fi    
}

    case "$action" in
    start)
      start
      ;;
    stop)
      stop
      ;;
    restart)
      stop
      start
      ;;
    status)
      status
      ;;
    *)usage
      exit 1
    esac

