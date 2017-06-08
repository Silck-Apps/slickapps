confdir="/etc/apache2/sites-available/"
sites="ispconfig helpdesk"
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
  esac
  docroot="/srv/www/$site.$domain/web"
  conffile=$confdir$site.$domain.vhost
  match="DocumentRoot \/srv\/www\/$site.$domain\/web"
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
