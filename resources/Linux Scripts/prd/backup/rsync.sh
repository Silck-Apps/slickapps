while getopts "f:b:s:l:" OPTION
do
        case $OPTION in
        f)
         folder=$OPTARG
         ;;
        b)
         backupdir=$OPTARG
         ;;
        s)
         server=$OPTARG
         ;;
        l)
         logdir=$OPTARG
         ;;
        esac
done
logfile=$logdir/rsync.log


if [ ! -d $backupdir/$folder/ ]
then
  mkdir -p $backupdir/$folder
fi

if [ $folder == "/var/lib/named" -o $folder == "/var/lib/dhcp" ]
then
  rsync -Auhvr --exclude "*proc*" $folder $backupdir/$folder | tee -a $logfile
else
  rsync -Auhvr $folder $backupdir/$folder | tee -a $logfile
fi




