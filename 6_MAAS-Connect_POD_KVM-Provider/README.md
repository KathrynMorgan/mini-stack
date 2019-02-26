# PART_6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]

![CCIO Hypervisor - MAAS Libvirt POD
Provider](https://github.com/KathrynMorgan/mini-stack/blob/master/6_MAAS-Connect_POD_KVM-Provider/web/drawio/maas-region-and-rack-ctl-on-ovs-sandbox.svg)

## Instructions:
#### 01. Provision Libvirt Host with maasctl ssh key & test
````sh
lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys    
lxc exec maasctl -- su -l maas /bin/bash -c 'ssh-keyscan -H precision >>~/.ssh/known_hosts'
lxc exec maasctl -- su -l maas /bin/bash -c 'virsh -c qemu+ssh://root@precision/system list --all'
````

#### 02. Connect your libvirt provider as a POD in MAAS
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

#### 03. Set instance kernel parameters
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
