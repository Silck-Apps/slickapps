dir="/srv/resources/software/mysql-proxy-0.8.3"
packages="libmysqlclient-devel lua51 lua51-devel glib2-devel libevent-devel gcc make"
#scriptdir=${0%/*}
scriptdir="/srv/resources/scripts/mysql-proxy"
conffile="$scriptdir/mysql-proxy.cnf"
servicefile="$scriptdir/mysql-proxy.service"

zypper -n install --force-resolution $packages
cd $dir
LD_LIBRARY_PATH="/usr/local/"
./configure
make
make install
cp $conffile /etc
chmod 660 /etc/mysql-proxy.cnf
cp $servicefile /etc/init.d/mysql-proxy
systemctl --system daemon-reload
chkconfig -a mysql-proxy
ldconfig
mysql-proxy -V
service mysql-proxy start
