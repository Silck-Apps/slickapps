domain='skdk.internal'
basedir="/srv/www/"
backupdir="/srv/backup"
logdir="/srv/backup/log/"
#dbuser="scripts_data"
#dbpass="new12day"
addservers="util01.$domain util02.$domain vmserv01.$domain vmserv02.$domain fs01.$domain rt01.$domain dmz01.$domain dmz02.$domain proxy01.$domain proxy02.$domain"
#sites=$(mysql -uscripts_data -pnew12day -hispcfg01.skdk.internal -Bse 'select 'domain' from 'dbispconfig'.'web_domain';')
#servers=$(mysql -hispcfg01.skdk.internal -uscripts_data -pnew12day -Bse `'select 'server_name' from 'dbispconfig'.'server';')
sites=$(mysql --login-path=scripts_no_host -hispcfg01.$domain -Bse 'select 'domain' from 'dbispconfig'.'web_domain';')
servers=$(mysql --login-path=scripts_no_host -hispcfg01.$domain -Bse 'select 'server_name' from 'dbispconfig'.'server';')
allservers=$servers" "$addservers
datestr=$(date +"%Y-%m-%d")
lastdate=$(date --date="-1 week" +"%Y-%m-%d")
scriptstart=`date`

echo "Backup start: $scriptstart"
echo "Current sites list"
echo ''
echo "$sites"
echo ''

for site in $sites
do
  dir="$basedir$site/web"
  lastsitebackup=$backupdir/websites/$lastdate"_"$site".tar.gz"


ssh root@ispcfg01 ". /srv/resources/scripts/backup/drush.sh -l $logdir -D $datestr -b $backupdir -s $site -d $dir | tee -a $logdir/drush.log"
#  if [ -f $lastsitebackup ]
#  then
#    echo "Removed old backup $lastsitebackup"
#    echo ''
#    rm $lastsitebackup
#  else
#    echo "old backup $lastsitebackup not found. Not removed"
#    echo ''
#  fi
done

for server in $servers
do
  databases=$(mysql --login-path=scripts_no_host -h$server -Bse 'show databases;')
  for database in $databases
  do
    if [[ "$database" != *_schema ]]
    then
      starttime=`date`
      mysqlbackuppath=$backupdir/databases/$server/$datestr"_"$database.sql
      mysqllastbackup=$backupdir/databases/$server/$lastdate"_"$database.sql
      echo "dumping database $database from host $server" | tee -a $logdir/mysql_backup.log
      echo "Backup path: $mysqlbackuppath" | tee -a $logdir/mysql_backup.log
      echo "Start: $starttime"  | tee -a $logdir/mysql_backup.log
      if [ ! -d $backupdir/databases/$server/ ]
      then
        mkdir -p $backupdir/databases/$server
      fi
      mysqldump --login-path=scripts_no_host -h$server $database > $mysqlbackuppath
      finishtime=`date`
      duration=$(($(date -d "$finishtime" +%s) - $(date -d "$starttime" +%s)))
      echo "dump completed at $finishtime" | tee -a $logdir/mysql_backup.log
      echo "Duration: $(($duration / 60)) minutes $(($duration % 60)) seconds." | tee -a $logdir/mysql_backup.log
      echo '' | tee -a $logdir/mysql_backup.log
#     if [ -f $mysqllastbackup ]
#      then
#        echo "Removed old backup $mysqllastbackup"
#       echo ''
#        rm $mysqllastbackup
#      else
#        echo "old backup $mysqllastbackup not found. Not removed"
#        echo ''
#      fi
    fi
  done
done

for server in $allservers
do
  folders=$(mysql --login-path=scripts_no_host -hispcfg01.skdk.internal scripts_data -Bse "select folder from backup_dirs where server = '$server'")
  rsyncdir=$backupdir/rsync/$server/
  if [ ! -d $rsyncdir ]
  then
    mkdir -p $rsyncdir
  fi
  for folder in $folders
  do
#    if [ ! -d $backupdir/rsync/$server/$folder/ ]
#    then
#     mkdir -p $backupdir/rsync/$server/$folder
#E    fi
    ssh root@$server ". /srv/resources/scripts/backup/rsync.sh -l $logdir -f $folder -b $rsyncdir -s $server | tee -a $logdir/rsync.log" 
  done
done
scriptfinish=`date`
duration=$(($(date -d "$scriptfinish" +%s) - $(date -d "$scriptstart" +%s)))
echo "Backup finish: $scriptfinish"
echo "Total Duration: $(($duration / 60)) minutes $(($duration % 60)) seconds."
. /srv/resources/scripts/backup/delete_old_backups.sh $backupdir
