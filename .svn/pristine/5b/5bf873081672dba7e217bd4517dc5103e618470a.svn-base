
OPTIND=1

usage()
{
cat<<EOF
Usage: $0 options

This script creates a new virtual Machine.

REQUIRED PARAMETERS:
  -n  New VM name
  -p  Port number for VRDE Connection via RDP
  -i  VRDE IP address

OPTIONAL PARAMETERS:
  -h  Shows this message
  -r  VM RAM amount
  -a  Host NIC
  -b  Base folder path. Default is $basefolder
  -c  Clone Existing vhd file and attach to vm
  -d  attach openSUSE disk to VM. Specify different path if required.

 Sorry! Please try again!


EOF
}
vmname=
isopath="/srv/resources/software/openSUSE-12.3-NET-i586.iso"
ram=512
nic=eth0
vrdeport=
basefolder=/srv/vms/
copyvhd=
attachcd=0
while getopts "c:d:hn:p:b:r:a:i:" OPTION 
do
	case $OPTION in
	h)
	 usage
	 return 
	 ;;
	n)
	 vmname=$OPTARG
	 ;;
	i)
	 vrdeip=$OPTARG
	 ;;
	p)
	 vrdeport=$OPTARG
	 ;;
	b)
	 basefolder=$OPTARG
	 ;;
	c)
	 copyvhd=$OPTARG
	 ;;
	r)
	 ram=$OPTARG
	 ;;
	a)
	 nic=$OPTARG
	 ;;
	d)
	 attachcd=1
	 if [ ! -z $OPTARG ]
	 then
	  isopath=$OPTARG
	 fi
	 ;;
	?)
	 usage
	 return
	 ;;
	esac
done

if [[ -z $vmname ]] || [[ -z $vrdeport ]]
then
  usage
  return
fi

vhdpath=$basefolder$vmname"/"$vmname".vhd"



vboxmanage createvm --name $vmname --ostype OpenSUSE --register --basefolder $basefolder
#vboxmanage modifyvm $vmname --memory $ram --boot1 disk --boot2 none --boot3 none --boot4 none --nic1 bridged --bridgeadapter1 $nic --vrde on --vrdeport $vrdeport --vrdeaddress $vrdeip
vboxmanage modifyvm $vmname --memory $ram --boot1 disk --boot2 none --boot3 none --boot4 none --nic1 bridged --bridgeadapter1 eth0 --nic2 bridged --bridgeadapter2 eth1 --vrde on --vrdeport $vrdeport --vrdeaddress $vrdeip
vboxmanage storagectl $vmname --name sata1 --add sata --sataportcount 1 --bootable on

if [ -z $copyvhd ]
then
vboxmanage createhd --filename $vhdpath --size 20000 --format VHD
else
vboxmanage clonehd $copyvhd $vhdpath --format VHD
fi
vboxmanage storageattach $vmname --storagectl sata1 --port 1 --type hdd --medium $vhdpath

if [ $attachcd -eq 1 ]
then
vboxmanage storagectl $vmname --name cd1 --add ide --bootable on
vboxmanage storageattach $vmname --storagectl cd1 --port 0 --device 0 --type dvddrive --medium $isopath
fi

chown -R vboxdrv:vboxusers $basefolder
chmod -R 775 $basefolder

#vboxmanage sharedfolder add $vmname --name resources --hostpath /home/resources --automount
#startvm $vmname
