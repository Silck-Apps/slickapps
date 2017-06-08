echo "sql query password"
#servers=$(mysql -hmysql -uscripts_data -p scripts_data -Bse 'select server from monitor_services')
#servers=$HOSTNAME
#for server in $servers
#do
	echo "server: $server"
	mysql_config_editor reset
	echo "password for mysql user scripts_data"
	mysql_config_editor set --login-path=scripts --user=scripts_data --host=mysql --password
	echo "password for mysql user scripts_data"
	mysql_config_editor set --login-path=scripts_no_host --user=scripts_data --password
	echo "password for mysql user bennettw"
	mysql_config_editor set --login-path=bennettw --user=bennettw --password
	echo "password for mysql user root"
	mysql_config_editor set --login-path=root --user=root --password
#done