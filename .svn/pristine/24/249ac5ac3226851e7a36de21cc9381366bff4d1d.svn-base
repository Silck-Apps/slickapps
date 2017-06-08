
dir="/srv/www"
scriptdir=${0%/*}
source /"srv/resources/scripts/functions.sh"
server=$(setsyncserver ${HOSTNAME: -2})

while [ 0 == 0 ]
do
  event=$(inotifywait -r -e modify -e attrib -e close_write -e move -e create -e delete $dir)
  if [ $? = 0 ] 
  then
    ssh $server  "unison $dir ssh://$HOSTNAME/$dir"
  fi
done

