#emailfrom="zypper_updates@i-fix.com.au"
#emailto="zypper_updates@i-fix.com.au"
smtpaddress="zypper_updates@i-fix.com.au"
#serverlist="util01 ispcfg01 ispcfg02 vmserv01 vmserv02 fs01 dmz01 dmz02 proxy01 proxy02 rt01"
serverlist=$(mysql --login-path=scripts scripts_data -Bse "select server from monitor_services")
wd="/srv/resources/scripts/updates/data/"
# serverlist=$1
for server in $serverlist
do

  newlist=$wd$server"_newlist"
  lastlist=$wd$server"_lastlist"
  difference=$wd$server"_difference"
  subject="Subject: New updates availible for "$server
  
  ssh $server "zypper -q ref"
  ssh $server "zypper --no-refresh lu > $newlist"
  if [ -e $lastlist ]
  then
   comm -23 $newlist $lastlist > $difference
   if [ -s $difference ]
   then
     if [ "$(cat $difference)" == "No updates found." ]
     then
      cat /dev/null > $difference
     fi
   fi
  else
   cat $newlist > $difference
  fi
  if [ -s $difference ]
  then
    echo "To:$smtpaddress" > $wd/email
    echo "From:$smtpaddress" >> $wd/email
    echo "Subject:$subject" >> $wd/email
    echo "" >> $wd/email
    cat $difference >> $wd/email
    cat $wd/email
#    echo $subject | cat - $difference | sendmail -t $emailto
    ssmtp $smtpaddress < $wd/email
    rm $wd/email
  fi
  if [ -e $lastlist ]
  then
    rm $lastlist
  fi
  rm $difference
  mv $newlist $lastlist
done
