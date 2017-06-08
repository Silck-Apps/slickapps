wwwdir="/srv/www/helpdesk"
BinDir="/srv/resources/software/rt-4.0.6"
DBtype="mysql"
DBName="request_tracker"
DBPassword="new12day"
webuser="wwwrun"
apache2_bin="/etc/init.d/apache2"
DBHost="mysql01"
firstrun=0
 
 match="false"
 if [ -d $wwwdir ]
 then
	match="true"
fi

if [ $match == "false" ]
then
	md $wwwdir
fi
#yast2 -i make gcc perl-DBD-mysql perl-ssleay perl-mcrypt-ssl fetchmail
cd $BinDir

#if [ $firstrun == 1 ]
#then
/usr/bin/perl -MCPAN -e shell
#fi

 ./configure --prefix=$wwwdir --with-db-type=$DBtype --with-db-database=$DBName --with-db-rt-pass=$DBPassword --with-web-user=$webuser --with-apachectl=$apache2_bin --enable-ssl-mailgate --with-db-host=$DBHost
 
 make testdeps
 
 read -p "Do you want to run Fixdeps? (y/n)"
 case $yn in
    [Yy]* ) 
		make fixdeps
		echo ''
		echo 'Fixdeps finished'
		echo ''
		echo "Running test deps"
		make testdeps;;
esac

make install
