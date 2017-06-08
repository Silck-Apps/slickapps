source '/srv/resources/scripts/functions.sh'
configdir="/root/.unison/"
scriptdir=$(pwd)
logdir="/var/log/ispconfig/unison/"

zypper -n install --force-resolution unison

if [ ! -d $configdir ]
then
  mkdir $configdir
fi

if [ ! -d $logdir ]
then
  mkdir $logdir
fi

cp $scriptdir/default.prf $configdir
