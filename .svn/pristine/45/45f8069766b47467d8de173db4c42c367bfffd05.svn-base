softwaredir="/srv/resources/software"

zypper -n install --force-resolution libnotify-tools libnotify-devel
ldconfig
cd $softwaredir
wget http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz
tar -zxf inotify-tools-3.14.tar.gz
cd inotify-tools-3.14/
./configure
make
make install

