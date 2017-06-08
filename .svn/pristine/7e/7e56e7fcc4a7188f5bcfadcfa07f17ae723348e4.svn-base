monitorfail=
deadservers=
#dbuser='scripts_data'
#dbpass='new12day'
#dbserver='mysql.skdk.internal'
dbport=3306
db='scripts_data'
tmpfile="/srv/resources/tmp/email.msg"

mailpass="sambo174"
emailsubject="Monitoring Notification"
emailto="wayne.bennett@i-fix.com.au"
emailfrom="webmaster@i-fix.com.au"

#mysqlstring="mysql -u$dbuser -p$dbpass -h$dbserver -P$dbport $db "
mysqlstring="mysql --login-path=scripts $db "
cssdateline="font-size:14px;font-family:Calibri,Helvetica,sans-serif;"
cssnoping="font-size:20px;font-family:Calibri,Helvetica,sans-serif;"
cssh1="font-size:26px;font-family:Calibri,Helvetica,sans-serif;"
csstable="font-family:Calibri,Helvetica,sans-serif;color:#333333;border-width:1px;border-color:#666666;border-collapse:collapse;"
cssth="font-size:16px;border-width:1px;padding:8px;border-style:solid;border-color:#666666;background-color:#dedede;"
csstd="font-size:14px;border-width:1px;padding:8px;border-style:solid;border-color:#666666;background-color:#ffffff;"

while getopts "fd:" OPTION
do
    case $OPTION in
		f)
			monitorfail="failed"
			;;
		d)
			deadservers="$OPTARG"
			;;
	esac
done

create_email() {
day=$(date +%e)
char=${day:${#day} - 1}
case $char in
  1)
    tail="st"
	;;
  2)
    tail="nd"
	;;
  3)
    tail="rd"
	;;
  *)
    tail="th"
	;;
esac
day=$day$tail
cat<<EOF
To:$emailto
From:$emailfrom
Subject:$emailsubject
Mime-Version: 1.0
Content-type: text/html; charset="iso-8859-1"

<HTML><P style="$cssdateline">Email composed on $(date +%A) $(date +%B) $day at $(date +%H:%M)</P>
EOF
}

function compose_email {

create_email > $tmpfile

if [ "$monitorfail" == "failed" ]
then
	echo "<P><H1 style="\"$cssh1\"">MySQL Connection Error</H1>" >> $tmpfile
	echo "MySQL failed to connect to get data. monitor failed.</P>" >> $tmpfile
	echo "</HTML>" >> $tmpfile
	
else
	servers=$($mysqlstring "-Bse select server from monitor_services")
	if [ "$deadservers" ]
	then
		echo "<P style="\"$cssnoping\"">These servers did not respond to ping test: $deadservers</P>" >> $tmpfile
	fi
	for server in $servers
	do
		result=$($mysqlstring "-BsHe select service,message from monitor_status where server = '$server' and status = 0")
		if [ ! -z "$result" ]
		then
			echo "<P><H1 style="\"$cssh1\"">Server: $server</H1>" >> $tmpfile
			echo "$result</P>" >> $tmpfile
		fi
	done
	echo "</HTML>" >> $tmpfile
	sed "s/<TABLE BORDER=1>/<TABLE style="\"$csstable\"">/g" $tmpfile > $tmpfile.sed
	mv $tmpfile.sed $tmpfile
	sed "s/<TH>/<TH style="\"$cssth\"">/g" $tmpfile > $tmpfile.sed
	mv $tmpfile.sed $tmpfile
	sed "s/<TD>/<TD style="\"$csstd\"">/g" $tmpfile > $tmpfile.sed
	mv $tmpfile.sed $tmpfile
fi
}

compose_email
ssmtp $emailto < $tmpfile
rm $tmpfile