while getopts "t:l:d:b:s:D:" OPTION
do
        case $OPTION in
        d)
         dir=$OPTARG
         ;;
        b)
         backupdir=$OPTARG
         ;;
        s)
         site=$OPTARG
         ;;
	D)
	 datestr=$OPTARG
	 ;;
	l)
	 logdir=$OPTARG
	 ;;
        esac
done
   echo $dir

 if [ -d $dir ]
 then
   cd $dir
    output=$(drush core-status drupal-version --pipe)
    starttime=`date`
    backuppath=$backupdir/"websites"/$datestr"_"$site".tar.gz"
#     output=$(cat $dir"/sites/default/default.settings.php" | grep Drupal)
   IFS=" " read -a line <<< $output
   if [[ "${line[0]}" == *drupal-version* ]]
   then
     starttime=`date`
#     backuppath=$backupdir/websites/$datestr"_"$site".tar.gz"
     echo "Site: $site" | tee -a $logdir/drush_backup.log
     echo "Backup Start $starttime." | tee -a $logdir/drush_backup.log
     echo "Backup Path: $backuppath" | tee -a $logdir/drush_backup.log
     drush ard --destination=$backuppath --overwrite >> $logdir/drush_backup.log
     finishtime=`date`
     duration=$(($(date -d "$finishtime" +%s) - $(date -d "$starttime" +%s)))
     echo "Backup finished at $finishtime" | tee -a $logdir/drush_backup.log
     echo "Elapsed time: $(($duration / 60)) minutes $(($duration % 60)) seconds." | tee -a $logdir/drush_backup.log
     echo '' | tee -a $logdir/drush_backup.log
   else
     echo "Site: $site" | tee -a $logdir/drush_backup.log
     echo "This isn't a drupal website. using Tar instead...." | tee -a $logdir/drush_backup.log
     tar -czf $backuppath .
     echo "Site backup complete" | tee -a $logdir/drush_backup.log
     echo '' | tee -a $logdir/drush_backup.log
   fi
   finishtime=`date`
   duration=$(($(date -d "$finishtime" +%s) - $(date -d "$starttime" +%s)))
 else
   echo "Can't find $site. No backup done"
   echo ''
fi
