md /srv/vms
zypper -n ar -f http://download.virtualbox.org/virtualbox/rpm/opensuse/11.4/virtualbox.repo
zypper -n install make gcc kernel-default-devel VirtualBox-4.2
useradd -g vboxusers -N -p new12day vboxdrv
chown -R vboxdrv:vboxusers /srv/vms
cp /srv/resources/scripts/system/bash.bashrc.local /etc/
service vboxdrv setup
vboxmanage extpack install /srv/resources/software/Oracle_VM_VirtualBox_Extension_Pack-4.2.10-84104.vbox-extpack
