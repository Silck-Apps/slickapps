

clientsdir="/srv/www/clients"
phpscriptsdir="/srv/www/php-fcgi-scripts"

clients=$(ls $clientsdir)
fcgidirs=$(ls $phpscriptsdir | grep -Ex 'web[0-9][0-9]')

for client in $clients
do
  chattr -i $clientsdir/$client/*
  chgrp -R $client $clientsdir/$client
  echo "client folder: $client group changed"
  ls -l

  webfolders=$(ls $clientsdir/$client | grep -Ex 'web[0-9][0-9]')
  for folder in $webfolders
  do
    echo "changing owner on $folder for $client"
    chown -R $folder $clientsdir/$client/$folder
    echo "Changing owner and group on $phpscriptsdir/$folder"
    echo "owner: $folder - Group: $client"
    chown -R "$folder:$client"  $phpscriptsdir/$folder
  echo "Next Folder........................"
  done
echo "Next Client ..................."


done
