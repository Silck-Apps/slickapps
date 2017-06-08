giturl="https://github.com/greggoryhz/Watcher/blob/master/"
gitfiles="LICENSE watcher.py jobs.yml README.md"
#configdir="/root/.watcher"
scriptdir=$(pwd)


#if [ ! -d $configdir ]
#then
#  md $configdir
#fi

cd $scriptdir

for file in $gitfiles
do
  wget -nd -Nr $giturl$file

  if [ $file == "watcher.py" ]
  then
    chmod +x ./watcher.py
  fi
done
rm robots.txt*
