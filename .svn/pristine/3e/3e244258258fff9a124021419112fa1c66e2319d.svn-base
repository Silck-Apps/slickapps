bashlocal="/etc/bashrc.local"

zypper -n install --force-resolution python python-pyinotify python-yaml


if [ ! -a $bashlocal ]
then
  touch $bashlocal
fi

echo 'alias watcher="python /srv/resources/scripts/watcher/watcher.py"' >> $bashlocal

. $bashlocal
