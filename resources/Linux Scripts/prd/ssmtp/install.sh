
zypper -n install --force-resolution gcc-c++ make

cd /srv/resources/software


wget http://ftp.de.debian.org/debian/pool/main/s/ssmtp/ssmtp_2.64.orig.tar.bz2
tar -jxf ssmtp_2.64.orig.tar.bz2

cd ssmtp-2.64
./configure
make
make install

cp /srv/resources/scripts/ssmtp/ssmtp.conf /usr/local/etc/ssmtp/
