# Part 4 -- KVM On Open vSwitch
###### Install and Configure Libvirt / KVM / QEMU on a Default Open vSwitch Network
Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/small-stack/blob/master/4_Bare-Metal_KVM-On-Open-vSwitch/web/drawio/KVM-On-Open-vSwitch.svg)

## Instructions: 
#### 1. Install Packages
````sh
sudo apt install -y qemu qemu-kvm qemu-utils libvirt-bin libvirt0
````
#### 2. Check Libvirt Status
````sh
sudo systemctl status libvirtd
````
#### 3. Destroy default NAT Network
````sh
sudo virsh net-destroy default
sudo virsh net-undefine default
````
#### 4. Write 'default' network json
Note! Change line ````bridge name='physical-net'```` to match your host's local network level bridge
````sh
cat <<EOF >>virsh-net-default.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='physical-net' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
#### 5. Create network from json
````sh
sudo virsh net-define virsh-net-default.json
sudo virsh net-start default
sudo virsh net-autostart default
````
#### 6. Verify virsh network:
````sh
sudo virsh net-list --all
sudo virsh net-dumpxml default
````

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/small-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/small-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part_6 MAAS POD Configuration on Libvirt Provider]: https://github.com/KathrynMorgan/small-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
