backupdir=$1
dirs="databases/ispcfg01.skdk.internal databases/ispcfg02.skdk.internal websites"
lastweek=$(date +%s)
((lastweek -= (60*60*24*7) ))
logfile="$backupdir/log/cleanup.log"

if [[ ! -a $logfile ]]
then
  touch $logfile
fi

echo "[$(date +%H:%M:%S\ --\ %d/%m/%Y)]: *** SESSION START ***" | tee -a $logfile
for dir in $dirs
do





  cd $backupdir/$dir/
  echo "*****  New Directory: $backupdir/$dir/" | tee -a $logfile
  files=$(ls)
  for file in $files
  do
    filedate=$(stat -c %Y $file)
    humanfiledate=$(echo $filedate | awk '{print strftime("%c",$1)}')
    shortdate=$(echo $filedate | awk '{print strftime("%d/%m/%Y",$1)}')

    if [[ $filedate < $lastweek ]]
    then
#      echo "Removing file: $file with date of $humanfiledate" | tee -a $logfile
      echo "[$shortdate]: Status: ** REMOVED ** -- $file" | tee -a $logfile
      rm $file 2> $logfile
    else
#      echo "$file not removed. Not old enough. file date is $humanfiledate" | tee -a $logfile

      echo "[$shortdate]: Status: ** Not Removed ** -- $file" | tee -a $logfile
    fi
  done


done

echo "[$(date +%H:%M:%S\ --\ %d/%m/%Y)]: *** SESSION ENDED ***" | tee -a $logfile
