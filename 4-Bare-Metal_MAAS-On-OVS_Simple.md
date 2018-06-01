###########################################################################################
## How to build a MAAS Server on a dedicated MAAS OVS Network
## NOTE: This assumes we configured a physical lan OVS Bridge 'physical-net'

###########################################################################################
## Create maas-net OVS bridge with LXD
lxc network create maas-net bridge.driver=openvswitch
lxc network set maas-net ipv4.address none
lxc network set maas-net ipv6.address none
lxc network set maas-net ipv4.nat false
lxc network set maas-net ipv6.nat false

###########################################################################################
## Write 'maas' network json
cat <<EOF >>virsh-net-default.json
<network>
  <name>maas</name>
  <forward mode='bridge'/>
  <bridge name='maas-net' />
  <virtualport type='openvswitch'/>
</network>
EOF

###########################################################################################
## Create & Start virsh 'maas' network
virsh net-define virsh-maas.network
virsh net-start maas
virsh net-autostart maas
virsh net-list

###########################################################################################
## Download Ubuntu Bionic Server ISO
wget -O /var/lib/libvirt/images/ubuntu-18.04-live-server-amd64.iso \
  http://releases.ubuntu.com/18.04/ubuntu-18.04-live-server-amd64.iso

###########################################################################################
## Create an Ubuntu Bionic server 'maas-controller' [Option A && Option B]

#### [OPTION A] Using LXD:
 # Create Container (assumes default network = 'physical-net')
   1. lxc launch ubuntu:bionic maas-controller
 # Enable privileged container
   2. lxc config set maas-controller security.privileged true
 # Attach 2nd Network to Container
   3. lxc network attach maas-net maas-controller eth1 eth1
 # Aquire console in container
   4. lxc exec maas-controller bash
 
 
#### [OPTION B] Using the Libvirtd+ISO Installer:
 # Connect virt-manager to Host QEMU via ssh
   0. Use virt-manager to attach to your host's QEMU
 # Download ISO for new VM
   1. wget -O /var/lib/libvirt/images/ubuntu-18.04-live-server-amd64.iso \
     http://releases.ubuntu.com/18.04/ubuntu-18.04-live-server-amd64.iso
 # Build new Bionic VM
   2. Use virt-manager to create a new vm 'maas-controller' \
      on the host's qemu via ssh and install with the bionic iso
 # Attach 2nd Network to VM
   3. Connect 2nd ethernet port to VM on 'maas-net' bridge
 # Aquire console in VM
   4. ssh to new maas-controller

###########################################################################################
## Configure 2nd NIC for your future maas network (Example config included)
vim /etc/netplan/50-cloud-init.yaml
****
network:
    version: 2
    ethernets:
        eth0:         ## physical-net interface
            dhcp4: true
        eth1:         ## maas-net interface
            addresses:
              - 172.10.0.1/16
****
netplan apply && netplan generate
reboot

###########################################################################################
## Install MAAS Region+Rack Controller Packages
## Install libvirt compatibility packages for maas-kvm-pods
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y
apt-add-repository ppa:maas/stable -y
apt install -y maas libvirt-bin

###########################################################################################
## Remove the auto-created libvirt bridge
virsh net-destroy default
virsh net-undefine default

###########################################################################################
## Create User & Login
sudo maas init

## Configure MAAS Region Controller to use your 'maas-net' bridge IP for PXE
## IE: 172.10.0.1
dpkg-reconfigure maas-region-controller

## Configure MAAS Rack Controller to use your 'maas-net' bridge IP for API etc.
## IE: http://172.10.0.1:5240/MAAS
dpkg-reconfigure maas-rack-controller
###########################################################################################
## Login to WebUI && Complete Setup
## IE: http://172.10.0.1:5240/MAAS
http://[physical-net_IP]:5240/MAAS

## Walk through on-screen setup:
 1. Confirm region name (I use braincraft.io)
 2. Set DNS Forwarder   (I use 8.8.8.8 etc.)
 3. Leave Ubuntu Archive* && apt/http proxy server as default for now
 4. Leave Image selection to default options for now
 5. Click 'Continue'
 6. Confirm SSH key(s) are imported for user
 7. click 'Go to dashboard'

## Confirm region and rack controller(s) show healthy
 1. Click "Controllers" tab
 2. click "maas-controller.maas"
 3. services should all be 'green' excluding dhcp* & ntp*
 
###########################################################################################
## Finish 'maas-net' configuration
 1. Click 'Subnets'
 2. Identify the 'maas-net' bridge network
 -- IE: '172.10.0.0/16' in this case
 3. For the 'maas-net' network click 'untagged' 'vlan' column engry
 4. Click 'Take action' Dropdown Menu (top right)
 5. Click 'Provide DHCP'
 6. Ensure start/end ranges & gateway IP are reasonable
 -- NOTE: Gateway IP should match the 'maas-controller' 'maas-net' interface
 -- IE:   In this Example: '172.10.0.1'
 7. Click 'Profide DHCP'

###########################################################################################
## Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy