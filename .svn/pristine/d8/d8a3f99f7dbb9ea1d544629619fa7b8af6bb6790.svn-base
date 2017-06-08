scriptsdir="/srv/resources/scripts/ispconfig/install"


zypper -n install --force-resolution findutils readline libgcc47 glibc-devel findutils-locate gcc flex lynx compat-readline4 db-devel wget gcc-c++ subversion make vim telnet cron iptables iputils man man-pages nano pico sudo

zypper -n install --force-resolution postfix postfix-mysql mysql mysql-community-server mysql-client python libmysqlclient-devel dovecot21 dovecot21-backend-mysql pwgen cron
#vi /etc/postfix/master.cf
cp $scriptsdir/postfix_master.cf /etc/postfix/master.cf

systemctl --system daemon-reload

chkconfig --add mysql
/etc/init.d/mysql start
chkconfig --add postfix
/etc/init.d/postfix start
chkconfig --add dovecot
/etc/init.d/dovecot start
mysql_secure_installation
zypper -n install --force-resolution amavisd-new clamav clamav-db zoo unzip unrar bzip2 unarj perl-DBD-mysql spamassassin

cp $scriptsdir/amavisd.conf /etc/
vi /etc/amavisd.conf

#vi /etc/clamd.conf
cp $scriptsdir/clamd.conf /etc

#vi /etc/freshclam.conf
cp $scriptsdir/freshclam.conf /etc

touch /var/log/clamd.log
touch /var/log/freshclam.log
chown vscan /var/log/clamd.log
chown vscan /var/log/freshclam.log
mkdir -p /var/run/clamav
ln -s /var/lib/clamav/clamd-socket /var/run/clamav/clamd
systemctl --system daemon-reload
chkconfig --add amavis
chkconfig --add clamd
chkconfig --add freshclam
/etc/init.d/amavis start
/etc/init.d/clamd start
/etc/init.d/freshclam start
freshclam --quiet >> /var/log/freshclam.log &
zypper -n install --force-resolution apache2 apache2-mod_fcgid apache2-devel php5-devel

zypper -n install --force-resolution php5-bcmath php5-bz2 php5-calendar php5-ctype php5-curl php5-dom php5-ftp php5-gd php5-gettext php5-gmp php5-iconv php5-imap php5-ldap php5-mbstring php5-mcrypt php5-mysql php5-odbc php5-openssl php5-pcntl php5-pgsql php5-posix php5-shmop php5-snmp php5-soap php5-sockets php5-sqlite php5-sysvsem php5-tokenizer php5-wddx php5-xmlrpc php5-xsl php5-zlib php5-exif php5-fastcgi php5-pear php5-sysvmsg php5-sysvshm ImageMagick curl apache2-mod_php5

cd /tmp/
wget http://pecl.php.net/get/uploadprogress-1.0.3.1.tgz
tar -zxf uploadprogress-1.0.3.1.tgz
cd uploadprogress-1.0.3.1
phpize
./configure
make
make install 

cd /tmp/
wget http://www.suphp.org/download/suphp-0.7.1.tar.gz
tar -zxf suphp-0.7.1.tar.gz
cd suphp-0.7.1/
./configure --prefix=/usr --with-apxs=/usr/sbin/apxs2 --with-apr=/usr/bin/apr-1-config
make
make install
#vi /etc/php5/cli/php.ini
cp /srv/resources/scripts/ispconfig/php.ini /etc/php5/cli

a2enmod suexec
a2enmod rewrite
a2enmod ssl
a2enmod actions
a2enmod suphp
a2enmod fcgid
chown root:www /usr/sbin/suexec2
chmod 4755 /usr/sbin/suexec2
chkconfig --add apache2
/etc/init.d/apache2 start
#vi /etc/apache2/errors.conf
cp $scriptsdir/errors.conf /etc/apache2/

zypper -n install --force-resolution pure-ftpd quota
cp $scriptsdir/pure-ftpd.conf /etc/pure-ftpd/
systemctl --system daemon-reload
chkconfig --add pure-ftpd
chkconfig --add quota
/etc/init.d/pure-ftpd start
/etc/init.d/quota start
zypper -n install --force-resolution bind

cd /tmp
wget http://downloads.sourceforge.net/project/awstats/AWStats/7.1/awstats-7.1.tar.gz?r=http%3A%2F%2Fawstats.sourceforge.net%2F&ts=1362215280&use_mirror=waix
wget http://olivier.sessink.nl/jailkit/jailkit-2.15.tar.gz
tar -zxf jailkit-2.15.tar.gz
cd jailkit-2.15/
./configure
make
make install
zypper -n install --force-resolution webalizer perl-Date-Manip fail2ban xntp
systemctl --system daemon-reload
chkconfig --add ntp
chkconfig --add fail2ban
/etc/init.d/fail2ban start
/etc/init.d/ntp start
cd /srv/resources/software/ispconfig3_install/install
php -q install.php
