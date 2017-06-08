dbuser=bennettw
dbpass=sambo174
dbrepeluser=replication
dbrepelpass=new12day
mysqlserver="ispcfg01.skdk.internal"
slaveserver="ispcfg02.skdk.internal"
otherdbs="dbispconfig_old scripts_data"
tmpfile="/srv/resources/tmp/databases.sql"
dumpdirs=0
dumprelaylogs=0
dumplogs=0
servers="$mysqlserver $slaveserver"
function echo_results {
  echo "Server: $server"
  echo "Slave State: '$slavestate'"
  echo "  IO Thread is $IOstatus"
  echo "  SQL Thread is $SQLstatus"
}

function script_output {

echo $IOstatus > "$1/$(echo $server | sed 's/.skdk.internal//g').MySQL-IO.status"
echo $SQLstatus > "$1/$(echo $server | sed 's/.skdk.internal//g').MySQL-SQL.status"
}

for server in $servers
do
  IOstatus=$(mysql -p$dbpass -u$dbuser -h$server -e 'show slave status\G' | grep Slave_IO_Running | tr -d ":" | sed -e 's/\<Slave_IO_Running\>//g')
  SQLstatus=$(mysql -p$dbpass -u$dbuser -h$server -e 'show slave status\G' | grep Slave_SQL_Running | tr -d ":" | sed -e 's/\<Slave_SQL_Running\>//g')
  slavestate=$(mysql -p$dbpass -u$dbuser -h$server -e 'show slave status\G' | grep Slave_IO_State | tr -d ":" | sed -e 's/\<Slave_IO_State\>//g' | sed -e 's/^ *//g' -e 's/ *$//g')
if [ $IOstatus == "Yes" ]
then
  IOstatus="Running"
else
  IOstatus="not Running"
fi

if [ $SQLstatus == "Yes" ]
then
  SQLstatus="Running"
else
  SQLstatus="Not Running"
fi

#if [ $(pwd) != "/srv/resources/scripts/monitoring" ]
if [ ! -d "$1" ]
then
  echo_results
else
  script_output $1
fi
done

