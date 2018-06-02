# CCIO Hypervisor
# How to get make an OVS bridge the default Libvirt VM Network
#
Prerequisites:
- [Part1 Single Port Host Network Configuration]

## Install Packages
apt install -y qemu qemu-kvm qemu-utils libvirt-bin libvirt0

## Check Libvirt Status
systemctl status libvirtd

## Destroy default NAT Network
virsh net-destroy default
virsh net-undefine default

## Write 'default' network json
cat <<EOF >>virsh-net-default.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='physical-net' />
  <virtualport type='openvswitch'/>
</network>
EOF

## Create network from json
virsh net-define virsh-net-default.json
virsh net-start default
virsh net-autostart default

<!-- Markdown link & img dfn's -->
[Part1 Single Port Host Network Configuration]: https://github.com/KathrynMorgan/small-stack/blob/master/1_Bare-Metal_Single-Port-OVS-Hypervisor/README.md
[Part2 ]
