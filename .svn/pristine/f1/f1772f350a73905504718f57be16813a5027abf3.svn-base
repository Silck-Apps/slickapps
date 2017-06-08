OPTIND=1
usage()
{
cat<<EOF
Install a new Drupal site with the desired profile and if desired can:

** import the following elements from an existing site
  - User Accounts
  - Permissions and Roles
  - 
** Configure Brisbane Locale and timezone
** download these packages:
   drush	drush_role	node_export	advanced_help
   views	date		menu_import	feeds
   captcha	taxonomy_access_fix		uuid
   wysiwyg	ctools
** enable these modules
   node_export_feeds	bulk_export menu_import taxonomy_access_fix
   captcha image_captcha	uuid	views	views_ui
   wysiwyg
** installs TinyMCE wysiwyg Editor




OPTIONS
  -h Displays this dialog
  -d Switch. DEV site install
  -s MySQL server name. Default is $DBServer
  -u MySQL username. Default is $DBUser
  -p MYSQL user's DB password. Default is $DBPassword
  -n Required field. Database Name

  DRUPAL INSTALL OPTIONS
  
  -i Profile to be used for install. Default is $drupal_profile
  -e admin account email address. Default is $account_mail
  -A admin account user name. Default is $account_name
  -P Admin account password.
  -c clean URL option. Must be 1 or 0. Default is $clean_url
  -S Site name for Drupal home page. Default is $site_name
  -D Site config file. Required field
  -E update notifications send to this email address. Default is $email_updates_to
  -x Do not copy content. Add this switch if not synching content from live site.
  
EOF
exit
}

function add_users()
{
i=0
while read LINE
 do 
	if [ $i != 0 ]
	then
		values=( $LINE )
		drupal_user=${values[0]}
		drupal_pass=${values[1]}
		drupal_email=${values[2]}
		drupal_role=${values[3]}
		drush ucrt $drupal_user --mail="""$drupal_email""" --password="""$drupal_pass"""
		if [ $drupal_role != "none" ]
		then
			drush urol """$drupal_role""" --name="""$drupal_user""" 
		fi
	fi
	i=$i+1
done < $1
}

download_only="none"
download_projects="none"
DBName="none"
#drupal_core_dir=/srv/resources/software/drupal/drupal-7.15/
DBUser=webdev01
DBServer=mysql01
DBPassword=new12day
drupal_profile=standard
account_mail="webmaster@i-fix.com.au"
account_name="i-fix"
account_password="R1m@dmin"
clean_url=0
site_name="Site-Install"
default_accounts=/srv/resources/scripts/drupal/default_accounts.txt
site_config="none"
copy_folders="none"
temp_files_location=/srv/resources/images.tar.gz
email_updates_to="drupal_updates@i-fix.com.au"
donot_copy_content=1
menu_names="none"
dir="/srv/www/$site_name/web"
#other_accounts="none"

while getopts "hds:p:u:n:i:A:c:S:U:D:E:xe:P:" OPTION
do
	case $OPTION in
	h)
	 usage
	 ;;
	d)
	 dir="/srv/www/dev.$site_name/web"
	 ;;
	s)
	 DBServer=$OPTARG
	 ;;
	p)
	 DBPassword=$OPTARG
	 ;;
	u)
	 DBUser=$OPTARG
	 ;;	
	n)
	 DBName=$OPTARG
	 ;;
	i)
	 drupal_profile=$OPTARG
	 ;;
	A)
	 account_name=$OPTARG
	 ;;
	P)
	 account_password=$OPTARG
	 ;;
	c)
	 clean_url=$OPTARG
	 if [ $clean_url != 1 -o $clean_url != 0 ]
	  then
	  usage
	 fi
	 ;;
	S)
	 site_name=$OPTARG
	 ;;
	U)
	 user_accounts=$OPTARG
	 ;;
	D)
	 site_config=$OPTARG
	 ;;
	E)
	 email_updates_to=$OPTARG
	 ;;
	x)
	 donot_copy_content=0
	 ;;
	e)
	 account_mail=$OPTARG
	esac
done
if [ $site_config == "none" -o $dir == "none" -o $DBName == "none" ]
then
	usage
fi
if [ $site_config != "none" ]
then
	. $site_config
fi
cd $dir
cp -r $drupal_core_dir* .

drush si $drupal_profile --db-url=mysql://$DBUser:$DBPassword@$DBServer/$DBName --account-mail=$account_mail --account-name=$account_name --account-pass=$account_password --clean-url=$clean_url --site-name="""$site_name"""

# add_users $user_accounts
 #if [ $other_accounts != "none" ]
 #then
#	add_users $other_accounts
# fi
if [ $download_only != "none" -o $download_projects != "none" ]
then
	drush -y dl $download_projects
fi
if [ $enabled_modules != "none" ]
then
	drush -y en $enable_modules
fi



drush -y vset date_default_timezone "Australia/Brisbane"
drush -y vset site_default_country "Australia"
drush -y vset site_mail $site_mail
drush -y vset theme_default $default_theme
php -r "print json_encode(array('$email_updates_to'));"  | drush vset --format=json update_notify_emails -


 add_users $user_accounts

if [ $donot_copy_content == 1 ]
then
	if [ $copy_folders != "none" ]
	then
	mkdir ./sites/all/files
		for folder in $copy_folders
		do
			ssh ispcfg01 "cd /srv/www/$copy_content_from/web/sites/all/files; tar -zcf $temp_files_location $folder/"
			tar -zxf $temp_files_location -C ./sites/all/files
			rm $temp_files_location
		done
	chown -R $filepermissions .
	chmod 775 ./sites/all/files
	fi
	ssh ispcfg01 "drush --root=/srv/www/$copy_content_from/web ne-export --type=$copy_content_types" | drush ne-import --uid=0
	if [ $menu_names != "none" ]
	then
		for menu in $menu_names
		do
			ssh ispcfg01 "drush --root=/srv/www/$copy_content_from/web me /home/resources/$menu $menu"
			drush mi /home/resources/$menu $menu --clean-import --link-content
			rm /home/resources/$menu
		done
	fi
fi
