scriptsdir="/srv/resources/scripts"
server="ispcfg01"
#if [ "$HOSTNAME" == "$server" ]
#then
	svn update $scriptsdir
	chmod -R 755 $scriptsdir
#else
#	echo "Please run on ispcfg01"
#fi
	