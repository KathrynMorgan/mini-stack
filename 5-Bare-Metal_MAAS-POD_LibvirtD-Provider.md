###########################################################################################
## How to Connect a 'Host' LibvirtD provider to a MAAS 'maas-controller' (In LXD or LIBVIRT Guest Server)
## NOTE: This assumes we configured MAAS in an existing LibvirtD/LXD/Baremetal OS as a DHCP Provider on OVS Bridge 'maas-net'

####
  Libvirtd will need the host's default network to provide maas-net bridge by default
  To do this, we will change the virsh net 'default' parent device to the 'maas-net' bridge
  We will also create a new 'physical-net' virsh network so you can retain access to its resources as required
####

###########################################################################################
## Write 'physical-net' network json, Create Network, && Set to start/autostart
cat <<EOF >virsh-physical-net.json
<network>
  <name>physical-net</name>
  <forward mode='bridge'/>
  <bridge name='physical-net' />
  <virtualport type='openvswitch'/>
</network>
EOF

virsh net-define virsh-physical-net.json
virsh net-start physical-net
virsh net-autostart physical-net

###########################################################################################
## Stop & re-configure virsh 'default' network && restart it with parent device 'maas-net'
virsh net-destroy default
virsh net-edit default    ## change 'bridge name' to 'maas-net'
**** 
  <bridge name='maas-net'/>
****
virsh net-start default

###########################################################################################
## Example for verification   ## [Note: both 'default' and 'maas' use parent device 'maas-net'
root@:~# virsh net-list --all
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
 maas                 active     yes           yes
 physical-net         active     yes           yes

###########################################################################################
## Create a host 'mgmt' interface on the 'maas-net' network bridge
ovs-vsctl add-port maas-net mgmt1 -- set interface mgmt1 type=internal
vim /etc/network/interfaces    ## add mgmt1 to auto up w/ static ip or dhcp assignment
                               ## If assigned via dhcp, MAAS server (should) give you a stable IP
****
allow-hotplug mgmt0
iface mgmt1 inet static
  address 172.10.0.10
  netmask 255.255.0.0
  mtu 1500
****
ifup mgmt1
ip a s mgmt1 (note ip address)

###########################################################################################
## Configure 'maas' user ssh keys & provision 'maas' keys on target libvirtd provider

  ## In MAAS Server
   1. sudo chsh -s /bin/bash maas
   2. sudo su - maas
   3. ssh-keygen -f ~/.ssh/id_rsa -N ''
   4. exit
   
  ## If your MAAS server is in LXD on the Host 'libvirtd' provider you are connecting
  ## Where 'maas-controller' is the name of your maas container, from the host run:
   1. lxc exec maas-controller -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys

  ## If your MAAS server NOT in LXD on the Host 'libvirtd' provider you are connecting
  ## Add the contents of '/var/lib/maas/.ssh/id_rsa.pub' to /root/.ssh/authorized_keys on the target libvirt provider
  
  ## In MAAS Server
   1. sudo su - maas
   2. virsh -c qemu+ssh://root@$172.10.0.10/system list --all #confirm you can see libvirt output from the host
 
  ## In MAAS WebUI
   1. click 'Pods' tab
   2. click 'Add pod'
   3. Name the pod EG: host-libvirtd-provider
   4. Select Pod type 'Virsh'
   5. Add the qemu libvirtd provider address
   -- Example: qemu+ssh://root@172.10.0.10/system
   6. Click 'add pod'
   7. Test pod by clicking on your new pod
   8. Click 'Take Action' (top right)
   9. fill in fields w/ minimum options
   10.Click 'compose' and inherit

## Set instance kernel parameters
 1. Click 'Settings'
 2. click 'General'
 3. Find 'Global Kernel Parameters'
 4. include your preferred params
 -- EG: debug console=ttyS0,38400n8 console=tty0
 -- NOTE: on the libvirt host you can do:
 -- -- virsh list (--all)
 -- -- virsh console $id    ## AKA: virsh console 1
 
 ## Login to the MAAS CLI
 https://docs.maas.io/2.1/en/manage-cli
 
 ## Create a new VM from the MAAS CLI
 https://docs.maas.io/2.2/en/manage-cli-comp-hw
 