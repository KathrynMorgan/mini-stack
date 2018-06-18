# PART_6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]

## Instructions:
#### 1. Confirm both 'default' & 'maas' virsh networks are present before continuing
````
root@:~# sudo virsh net-list --all
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
 maas                 active     yes           yes
````
#### 2. Create a new virtual host 'mgmt' interface on the 'maas-net' ovs bridge
````
sudo ovs-vsctl add-port maas-net mgmt1 -- set interface mgmt1 type=internal
````
#### 3. Write ifupdown network script for mgmt1
````
sudo vim /etc/network/interfaces
````
Example:
````
allow-hotplug mgmt1
iface mgmt1 inet static
  address 172.10.0.10
  netmask 255.255.0.0
  mtu 1500
ifup mgmt1
````
Raise mgmt1 interface
````
sudo ifup mgmt1
````
Confirm interface configured correctly
````
ip a s mgmt1 (note ip address)
````
#### 4. Generate 'maas' user ssh keys
[ In MAAS Server ]
1. Set 'maas' user shell <br/>
`sudo chsh -s /bin/bash maas`
2. Change to maas user shell <br/>
`sudo su - maas`
3. Generate SSH keys for 'maas' user <br/>
````ssh-keygen -f ~/.ssh/id_rsa -N ''````

#### 5. Provision libvirt host with MAAS user public ssh key [ /var/lib/maas/.ssh/id_rsa.pub ]
* If you built MAAS server in an LXD container on the libvirt host you are connecting as a pod then copy in one command: <br/>
    `lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys`

* If your MAAS server is NOT in LXD on the host 'libvirt' provider you are connecting to then: <br/>
Add the contents of '/var/lib/maas/.ssh/id_rsa.pub' to /root/.ssh/authorized_keys on the target libvirt provider

#### 6. Confirm the MAAS server's user 'maas' can reach the virsh console of the target libvirt provider
[ In MAAS Server ]
1. Change to 'maas' user shell <br/>
`sudo su - maas`
2. Test virsh command over ssh. <br/>
`virsh -c qemu+ssh://root@172.1.0.100/system list --all`
3. Confirm virsh output success and no passwords are required

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
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/small-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/small-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
