

scriptdir=${0%/*}


#mkdir /srv/resources
#mount.cifs //files/resources /srv/resources -o username=root,passsword=R1m@dmin


/srv/resources/scripts/system/after.local/enable.sh
/srv/resources/scripts/ispconfig/install/install.sh
cp /srv/resources/scripts/mysql/$HOSTNAME.my.cnf /etc/
mysql --login-path=root -h$HOSTNAME -e "create user 'bennettw'@'%' identified by 'sambo174'; grant all privileges on *.* to 'bennettw'@'%' identified by 'sambo174' with grant option; flush privilegs;"
service mysql restart
/srv/resources/scripts/mysql/repair_replication.sh -d
/srv/resources/scripts/unison/install.sh
/srv/resources/scripts/inotify-tools/install.sh


