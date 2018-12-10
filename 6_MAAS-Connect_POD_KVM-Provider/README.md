# PART_6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]

## Instructions:
#### 2. Add mgmt2 netplan config
````sh
cat <<EOF > /etc/netplan/80-mgmt2.yaml
# Configure mgmt2 on 'maas' bridge
# For more configuration examples, see: https://netplan.io/examples
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt2:
      dhcp4: true
EOF
````

#### 4. Generate unique MAC address for mgmt2 iface
````sh
export HWADDRESS=$(echo "$HOSTNAME lan mgmt2" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
````

#### 5. Create LAN Bridge && add LAN Host MGMT2 Virtual Interface to Bridge
````sh
ovs-vsctl add-port maas mgmt2 -- set interface mgmt2 type=internal -- set interface mgmt2 mac="$HWADDRESS"
````

#### 00. Set Static IP in OpenWRT Gateway WebUI for Libvirt Host mgmt2 Interface    


#### 1. Set 'maas' user shell & Generate SSH keys for 'maas' user:    
( In maasctl Container )    
````sh
chsh -s /bin/bash maas    
su --login maas /bin/bash -c "ssh-keygen -f ~/.ssh/id_rsa -N ''"    
````

#### 5. Provision libvirt host with MAAS user public ssh key
( /var/lib/maas/.ssh/id_rsa.pub )    
````sh
lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys    
````

#### 0. Test maasctl ssh key provisioning
````sh
lxc exec maasctl -- su --login maas /bin/bash -c 'virsh -c qemu+ssh://root@192.168.2.21/system list
--all'
````

#### 6. Confirm the MAAS server's user 'maas' can reach the virsh console of the target libvirt provider
( In MAAS Server )    
a. Change to 'maas' user shell    
`sudo su - maas`    
b. Test virsh command over ssh    
`virsh -c qemu+ssh://root@192.168.2.21/system list --all`    
c. Confirm virsh output success and no passwords are required    

#### 7. Connect your libvirt provider as a POD in MAAS
[ In MAAS WebUI ]
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

#### 8. Set instance kernel parameters
[ In MAAS WebUI ]
1. Click 'Settings'
2. click 'General'
3. Find 'Global Kernel Parameters'
4. Include your preferred kernel boot arguments
5. Save
Example: `debug console=ttyS0,38400n8 console=tty0` <br/>
Usage:
[ on the libvirt host ]
    1. `virsh list (--all)
    2. `virsh console $id`

 <!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
