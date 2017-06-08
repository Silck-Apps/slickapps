#dbuser=bennettw
#dbpass=sambo174
dbrepeluser=replication
dbrepelpass=new12day
mysqlserver="ispcfg01.skdk.internal"
slaveserver="ispcfg02.skdk.internal"
tmpfile="/srv/resources/tmp/databases.sql"
dumpdirs=0
dumprelaylogs=0
dumplogs=0

OPTIND=1

usage()
{
cat<<EOF
Usage: $0 options

This script repairs mySQL replication.

Running this script with no options simply stops the slave process,
changes the master details and restarts the slave.

OPTIONAL PARAMETERS:
  -h  Shows this message
  -r  delete relay logs 
  -l  delete binary logs
  -d  dumps all replicated databases from $mysqlserver to $slaveserver 

EOF
}




while getopts "hrld" OPTION
do
        case $OPTION in
    	h)
	 usage
	 return
	 ;;
        d)
         dumpdirs=1
         ;;
        r)
         dumprelaylogs=1
         ;;
	l)
	 dumplogs=1
	 ;;
	*)
	 usage
	 echo "Sorry! Please try again!"
	 return
	 ;;
        esac
done

function stopslave {
for server in $servers
do
echo "Stopping slave on $server"
mysql --login-path=bennettw -h$server -Bse "stop slave;"

done
}

servers="$mysqlserver $slaveserver"

for db in $ignoredbs
do
  dbs=$(echo $dbs | sed -e "s/\<$db\>//g")
done

stopslave

if [ $dumpdirs == 1 ]
then
  dbs=$(mysql --login-path=bennettw -h$mysqlserver -Bse 'show databases;')
  ignoredbs=$(mysql --login-path=bennettw -h$mysqlserver  -e "show slave status\G" | grep Replicate_Ignore_DB | tr -d ":" | sed -e 's/\<Replicate_Ignore_DB\>//g' | sed -e 's/,/ /g')
  for db in $ignoredbs
  do
    dbs=$(echo $dbs | sed -e "s/\<$db\>//g")
  done
  echo 'Dumping databases'
  mysqldump --login-path=bennettw -h$mysqlserver --databases $dbs > $tmpfile
  echo 'Applying Dump file'
  mysql --login-path=bennettw -h$slaveserver < $tmpfile
  rm $tmpfile
fi
if [ $dumplogs == 1 -o $dumprelaylogs == 1 ]
then
  datadir=$(mysql --login-path=bennettw -h$mysqlserver -Bse "show variables like 'datadir';" | sed -e 's/\<datadir\>//g')
  echo $datadir
  for server in $servers
  do
    echo "Stopping mySQL service on $server"
    ssh root@$server '/etc/init.d/mysql stop'
 done
  if [ $dumplogs == 1 ]
  then
    for server in $servers
    do
      echo "dumping binary logs from $server"
      ssh root@$server "cd $datadir; rm mysql-bin.*"
    done
  fi
  if [ $dumprelaylogs == 1 ]
  then
    for server in $servers
    do
      echo "Dumping relay logs from $server"
      ssh root@$server "cd $datadir; rm mysqld-relay-bin.* relay-log.info"
    done
  fi
  for server in $servers
  do
    echo "Starting mySQL service on $server"
    ssh root@$server '/etc/init.d/mysql start'
  done
  stopslave
fi

for server in $servers
do

if [ $server == $slaveserver ]
then
  slaveserver=$mysqlserver
fi

position=$(mysql --login-path=bennettw -h$server -Bse 'show master status \G' | grep Position:)
IFS=" " read -a line <<< $position
position=${line[1]}
binlogfile=$(mysql --login-path=bennettw -h$server -Bse 'show master status \G' | grep File:)
IFS=" " read -a line <<< $binlogfile
binlogfile=${line[1]}

echo "changing master details on $slaveserver"
echo "Master: $server"
echo "Log File: $binlogfile"
echo "Position: $position"
mysql --login-path=bennettw -h$slaveserver -Bse "CHANGE MASTER TO MASTER_HOST='$server', MASTER_USER='$dbrepeluser', MASTER_PASSWORD='$dbrepelpass', MASTER_LOG_FILE='$binlogfile', MASTER_LOG_POS=$position;"
echo "Starting slave on $slaveserver"
mysql --login-path=bennettw -h$slaveserver -Bse "start slave;"
done
