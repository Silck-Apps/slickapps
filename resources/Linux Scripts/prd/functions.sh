alias md=mkdir

function setsyncserver {
servername="ispcfg"
case $1 in
        "01")
          server=$servername"02"
          ;;
        "02")
          server=$servername"01"
	  #server=$servername"-dev"
          ;;
	"ev")
	  server=$servername"02"
	  ;;
        *)
esac
echo $server
}

function getinterface {
# $1 server
interfaces=$(ssh $1 "ls /etc/sysconfig/network/ifcfg-eth*" | sed 's/\/etc\/sysconfig\/network\/ifcfg-//g')
  for interface in $interfaces
  do
    ip=$(echo $(ssh $1 "ifconfig $interface" | awk {'print $2'}) | awk {'print $2'} | sed 's/addr://g')
	if [ "$ip" != "BROADCAST" ]
	then
	  echo $interface
	else
	  echo "No IP address"
	fi
  done
}

function getip {
# $1 server
# $2 interface
echo $(ssh $1 "ifconfig $2" | awk {'print $2'}) | awk {'print $2'} | sed 's/addr://g'
}

function getinterfacemac {
# $1 server
# $2 interface
echo $(ssh $1 "ifconfig $2" | awk {'print $5'}) | awk {'print $1'}
}

function test_connection {
	unset -v dead
	unset -v alive
	for server in $1
	do
		result=$(echo $(ping $server -q -c 10) | awk {'print $16'})
		if [ $result -lt 5 ] || [ -z "$result" ]
		then
			dead+=( $server )
		else
			alive+=( $server )
		fi
	done
}