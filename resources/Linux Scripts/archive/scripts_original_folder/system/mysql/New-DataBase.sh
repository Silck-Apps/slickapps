OPTIND=1
usage()
{
cat<<EOF
Create new Database and grant permissions

OPTIONS
  -h Displays this dialog
  -H MySQL hostname portion of the user credentials. Default is $MySQLClient
  -m MySQL server name. Default is $DBServer
  -u MySQL username. Default is $DBUser
  -p MYSQL user's DB password. Default is $DBPassword
  -P MySQL server root password for connection.
  -n Required field. New Database Name

EOF
exit
}

DBServer=mysql01.i-fix.internal
DBUser=webdev01
MySQLClient=webdev01.i-fix.internal
DBPassword=new12day
RootPassword="R1m@dmin"
NewDataBase="none"

while getopts "hH:m:p:P:n:u:" OPTION
do
	case $OPTION in
	h)
	 usage
	 ;;
	H)
	 MySQLClient=$OPTARG
	 ;;
	m)
	 DBServer=$OPTARG
	 ;;
	p)
	 DBPassword=$OPTARG
	 ;;
	P)
	 RootPassword=$OPTARG
	 ;;
	n)
     NewDataBase=$OPTARG
	 ;;
	u)
	 DBUser=$OPTARG
	esac
done

mysqlconnect="mysql -h$DBServer -p$RootPassword"
mysqladddb="CREATE DATABASE $NewDataBase;"
mysqlgrant="GRANT ALL ON $NewDataBase.* TO '$DBUser'@'$MySQLClient' IDENTIFIED BY \"$DBPassword\";"
mysqlflush="FLUSH PRIVILEGES;"
logfile="/var/log/custom/New-Database.log"

if [ $NewDataBase == "none" ]
then
echo "You must specify at least a new database name!"
echo ""
usage
exit
fi

echo "Creating new database: $NewDataBase" 2>&1 | tee -a $logfile
echo $mysqladddb | $mysqlconnect 2>&1 | tee -a $logfile
	if [ $DBUser != "webdev01" ]
	then
		echo "Adding permissions on Server $DBServer for user $DBUser and Database $NewDataBase" 2>&1 | tee -a $logfile
		echo $mysqlgrant | $mysqlconnect 2>&1 | tee -a $logfile
	fi
