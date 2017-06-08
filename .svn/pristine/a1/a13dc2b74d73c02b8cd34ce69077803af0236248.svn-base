OPTIND=1
usage()
{
cat<<EOF
Rename mysql database

OPTIONS
  -h Displays this dialog
  -H MySQL hostname portion of the user credentials. Default is $MySQLClient
  -m MySQL server name. Default is $DBServer
  -u MySQL username. Default is $DBUser
  -p MYSQL user's DB password. Default is $DBPassword
  -P MySQL server root password for connection.
  -t Temp file. Default is $TempFile
  -n Required field. New Database Name
  -o Required field. Old Database name
  -d Drop the Old Database. Default is $DropOldDB

EOF
exit
}

choice()
{
cat<<EOF
You are about to perform the following actions:
* Add new data base $NewDataBase on $DBServer
* Grant All permissions to $DBUser@$MySQLClient
* Drop database $OldDataBase and revoke all permissions for $DBUser. You must specify -d to not drop the database.


EOF
read -p "Continue - (y/n): " yn
case $yn in
    [Nn]* ) exit;;
esac
}

DBServer=mysql01.i-fix.internal
DBUser=webdev01
MySQLClient=webdev01.i-fix.internal
DBPassword=new12day
RootPassword="R1m@dmin"
TempFile=/tmp/db.dump.sql
NewDataBase="none"
OldDataBase="none"
DropOldDB="Yes"

while getopts "hH:m:p:P:t:n:o:u:d" OPTION
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
	t)
	 TempFile=$OPTARG
	 ;;
	n)
     NewDataBase=$OPTARG
	 ;;
	o)
	 OldDataBase=$OPTARG
	 ;;
	u)
	 DBUser=$OPTARG
	;;
	d)
	 DropOldDB="No"
	esac
done



mysqldump="mysqldump -h$DBServer -p$RootPassword"
mysqlconnect="mysql -h$DBServer -p$RootPassword"
mysqladddb="CREATE DATABASE $NewDataBase;"
mysqldropdb="DROP DATABASE $OldDataBase;"
mysqlgrant="GRANT ALL ON $NewDataBase.* TO '$DBUser'@'$MySQLClient' IDENTIFIED BY \"$DBPassword\";"
mysqlrevoke="REVOKE ALL PRIVILEGES ON $OldDataBase.* FROM '$DBUser'@'$MySQLClient';"
mysqlflush="FLUSH PRIVILEGES;"
logfile="/var/log/custom/Rename-Database.log"

if [ $NewDataBase == "none" -o $OldDataBase == "none" ]
then
echo "You must specify at least a new and old database name!"
echo ""
usage
exit
fi

choice

echo "***********************************************************************" 2>&1 | tee -a $logfile
echo "dumping current Database: $OldDataBase" 2>&1 | tee -a $logfile
$mysqldump $OldDataBase > $TempFile
echo "Creating new database: $NewDataBase" 2>&1 | tee -a $logfile
echo $mysqladddb | $mysqlconnect 2>&1 | tee -a $logfile
	if [ $DBUser != "webdev01" ]
	then
		echo "Adding permissions on Server $DBServer for user $DBUser and Database $NewDataBase" 2>&1 | tee -a $logfile
		echo $mysqlgrant | $mysqlconnect 2>&1 | tee -a $logfile
	fi
echo "dumping temp file to new database" 2>&1 | tee -a $logfile
$mysqlconnect $NewDataBase < $TempFile 2>&1 | tee -a $logfile
if [ $DropOldDB == "Yes" ]
then
	if [ $DBUser != "webdev01" ]
	then
		echo "Revoking permissions for $DBUser from $OldDataBase on $DBServer" 2>&1 | tee -a $logfile
		echo $mysqlrevoke | $mysqlconnect 2>&1 | tee -a $logfile
	fi
echo "Dropping old Database $OldDataBase" 2>&1 | tee -a $logfile
echo $mysqldropdb | $mysqlconnect 2>&1 | tee -a $logfile
else
echo "-d option specified. Database $OldDataBase was not dropped!" 2>&1 | tee -a $logfile
fi

rm $TempFile
echo $mysqlflush | $mysqlconnect 2>&1 | tee -a $logfile