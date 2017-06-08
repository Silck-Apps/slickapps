dirs="resources backup"
resources_share="//files/resources"
resources_dir="/srv/resources"
smb_options="username=root,password=R1m@dmin"
enable_path=$resources_dir"/scripts/system/after.local/"

yast2 -i samba-client
cd /srv
for dir in $dirs; do md $dir; done
mount.cifs $resources_share $resoures_dir -o $smb_options
cd $enable_path
. enable.sh
