confdir="/etc/apache2/sites-available/"
sites="ispconfig helpdesk svn"
domain="i-fix.com.au"
internaldomain="skdk.internal"

for site in $sites
do
  case $site in
    "ispconfig")
      url="http:\/\/ispcfg01.$internaldomain:8080\/"
    ;;
    "helpdesk")
      url="http:\/\/rt01.$internaldomain:8080\/"
    ;;
	"svn")
	  url="http:\/\/fs01.$internaldomain:80\/"
	 ;;
  esac
  
  if [ $site == "svn" ]
  then
    docroot="/srv/www/$site.localhostwebhosting.com.au/web"
	conffile="$confdir$site.localhostwebhosting.com.au.vhost"
	match="DocumentRoot \/srv\/www\/$site.localhostwebhosting.com.au\/web"
  else
    docroot="/srv/www/$site.$domain/web"
    conffile=$confdir$site.$domain.vhost
    match="DocumentRoot \/srv\/www\/$site.$domain\/web"
  fi
  insert="proxypass \/ $url \n proxypassreverse \/ $url \n"


  sed -i "s/$match/$match\n$insert/" $conffile

#  output=$(cat $conffile)
#  IFS=" " read -a lines <<< $output
#  i=0
#  for line in $Lines
#  do
#  if [[ "$line[i]}" == DocumentRoot* ]]
#  then
#    echo 'proxypass / $url' >>
#  fi
#  done
done
/etc/init.d/apache2 restart
