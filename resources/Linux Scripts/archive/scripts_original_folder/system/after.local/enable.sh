cp /srv/resources/scripts/system/after.local/after-local.service /lib/systemd/system/
systemctl enable /lib/systemd/system/after-local.service
cp /srv/resources/scripts/system/after.local/after.local /etc/init.d/

echo "alias List-MysqlDBs='echo \"show databases;\" | mysql -hmysql01 -pR1m@dmin'" >> /etc/init.d/after.local
echo "alias Rename-Database=/home/resources/scripts/system/mysql/Rename-Database.sh" >> /etc/init.d/after.local
echo "alias Add-Database=/home/resources/scripts/system/mysql/New-DataBase.sh" >> /etc/init.d/after.local


vi /etc/init.d/after.local
