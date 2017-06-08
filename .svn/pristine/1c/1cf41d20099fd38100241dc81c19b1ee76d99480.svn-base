dir="/etc/apache2/sites-available"
timeout=30
logfile="sites-available.log"

logdir="/var/log/ispconfig/unison/"
logpath=$logdir$logfile
servername="ispcfg"
servernumber=(${HOSTNAME: -2})

case $servernumber in
        "01")
          server=$servername"02"
          ;;
        "02")
          server=$servername"01"
          ;;
        *)
esac
while [ 0 == 0 ]
do
  unison -batch -auto -group -owner -terse $dir ssh://$server/$dir > $logpath
  sleep $timeout
done
