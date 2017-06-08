servers='ispcfg01 ispcfg02'
services='vmail www'
piddir='/etc/ispconfig-data-replication'
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

for server in $1
do
  for service in $services
  do
    pid=$(ssh $server "cat $piddir/$service.pid")
    process=$(ssh $server "ps --no-headers -p $pid" | awk '{print $1}')
    if [ -z "$process" ]
    then
      process="none"
    fi
    case $process in
      $pid) echo "Running" > "$2/$server.$service.status" 
      ;;
      none) echo "Not found" > "$2/$server.$service.status"
      ;;
      *) echo "error" > "$2/$server.$service.status"
      ;;

    esac
  done

done


}

if [ $(pwd) != "/srv/resources/scripts/monitoring" ]
then
  echo_result "$servers"
else
  script_output "$servers" $1
fi
