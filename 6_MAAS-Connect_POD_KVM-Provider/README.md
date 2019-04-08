# PART_6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

-------
Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]

![CCIO Hypervisor - MAAS Libvirt POD Provider](https://github.com/KathrynMorgan/mini-stack/blob/master/6_MAAS-Connect_POD_KVM-Provider/web/drawio/maas-region-and-rack-ctl-on-ovs-sandbox.svg)

-------
#### 01. Provision Libvirt Host with maasctl ssh key & test virsh commands over ssh
````sh
lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys        
lxc exec maasctl -- su -l maas /bin/bash -c 'ssh-keyscan -H 10.10.0.2 >>~/.ssh/known_hosts'
lxc exec maasctl -- su -l maas /bin/bash -c 'ssh -oStrictHostKeyChecking=accept-new root@10.10.0.2 hostname'
lxc exec maasctl -- su -l maas /bin/bash -c 'virsh -c qemu+ssh://root@10.10.0.2/system list --all'
````

#### 02. Connect your libvirt provider as a POD in MAAS
````sh
lxc exec maasctl -- /bin/bash -c 'maas admin pods create type=virsh name=mini-stack.maas power_address=qemu+ssh://root@10.10.0.2/system cpu_over_commit_ratio=10 memory_over_commit_ratio=10'
````

#### 03. Test create new VM in your virsh pod:
```sh
lxc exec maasctl -- /bin/bash -c 'maas admin pod compose 1 cores=2 memory=2048 "storage=root:32(default)"'
virsh list --all
virsh console $new_vm_id
```
NOTE: Use key conbination "Ctrl+Shift+]" to exit virsh console

-------
## Next sections
- [PART_7 Juju MAAS Cloud]
- [PART_8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part_0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/0_Host_System_Prep
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[PART_6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[PART_7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[PART_8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Prep
