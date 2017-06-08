


#/srv/resources/scripts/ispconfig/data-replication/vmail.sh &>> /var/log/ispconfig/data-replication/vmail-replication.log &


#echo $! > /etc/ispconfig-data-replication/vmail.pid


#!/bin/bash
#
# haproxy: Start haproxy in daemon mode
#
# Author: OpenX
#

OPTIND=1

usage()
{
cat<<EOF
Usage: $0 options

This script starts stops and restarts replication services

REQUIRED PARAMETERS:
  -a Action. Stop, start or restart services

OPTIONAL PARAMETERS
  -h show help
  -s service to manipulate. vmail or www if ommitted then both services manipulated
  -S server to manipulate. ispcfg01 or ispcfg02. if ommitted then both servers manipulated.
  -i Kill all inotifywait processes. assumes "-a stop" with no other options supplied

EOF
}

services="vmail www"
servers="ispcfg01 ispcfg02"

scriptdir="/srv/resources/scripts/ispconfig/data-replication"
logdir="/var/log/ispconfig/data-replication"
piddir="/etc/ispconfig-data-replication"

while getopts "a:S:s:hi" OPTION
do
        case $OPTION in
        h)
         usage
         exit
         ;;
        s)
	 services=$OPTARG
	 ;;
	S)
	 servers=$OPTARG
	 ;;
	a)
	 action=$OPTARG
         ;;
	i)
	 action="killall"
	 ;;
	?)
         usage
         exit
         ;;
        esac
done

startservice () {
cat<<EOF
$scriptdir/start-replication.sh $1 &>> $logdir/$1-replication.log &
echo \$! > $piddir/$1.pid
EOF
}

start(){

    pid=$(ssh $server "cat $piddir/$service.pid")
    process=$(ssh $server "ps --no-headers -p $pid" | awk '{print $1}')

#PID=$(cat program.pid)
#if [ -e /proc/${PID} -a /proc/${PID}/exe -ef /usr/bin/program ]; then
#echo "Still running"
#fi


    if [ -z $process ]
    then

    echo "Starting $service replication on $server......"
    ssh $server "$(startservice $service)"

    else
      echo "Replication service already running. Process ID: $process....... This instance was not started......."

    fi

}

stop(){
    echo "Stopping $service replication on $server..."
    pid=$(ssh $server "cat $piddir/$service.pid")
    inotifypid=$(ssh $server "ps --no-headers --ppid $pid" | awk '{print $1}')
    echo "     Stopping prcesses $pid and $inotifypid on server $server......."
    ssh $server "kill $pid $inotifypid" 
}

for server in $servers
do
  for service in $services
  do
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
    killall)
      stop
      ;;
    *)usage
      exit 1
    esac

  done


  if [ $action == "killall" ]
  then
    echo "killing inotifywait processes on $server......"
    ssh $server 'killall inotifywait'
  fi

done
