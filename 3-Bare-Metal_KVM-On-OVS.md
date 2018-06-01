###########################################################################################
## How to get make an OVS bridge the default Libvirt VM Network
## NOTE: This assumes we're attaching to OVS Bridge 'physical-net'

###########################################################################################
## Install Packages
apt install -y qemu qemu-kvm qemu-utils libvirt-bin libvirt0

###########################################################################################
## Check Libvirt Status
systemctl status libvirtd

###########################################################################################
## Destroy default NAT Network
virsh net-destroy default
virsh net-undefine default

###########################################################################################
## Write 'default' network json
cat <<EOF >>virsh-net-default.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='physical-net' />
  <virtualport type='openvswitch'/>
</network>
EOF

###########################################################################################
## Create network from json
virsh net-define virsh-net-default.json
virsh net-start default
virsh net-autostart default