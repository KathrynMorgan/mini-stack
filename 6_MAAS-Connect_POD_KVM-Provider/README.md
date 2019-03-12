# PART_6 -- MAAS Connect POD on KVM Provider
###### Enable MAAS Control over Libvirt / KVM / QEMU Provider via POD method

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]

![CCIO Hypervisor - MAAS Libvirt POD Provider](https://github.com/KathrynMorgan/mini-stack/blob/master/6_MAAS-Connect_POD_KVM-Provider/web/drawio/maas-region-and-rack-ctl-on-ovs-sandbox.svg)

## Instructions:
#### 01. Provision Libvirt Host with maasctl ssh key & test
````sh
lxc exec maasctl -- /bin/bash -c 'echo "192.168.1.2 mini-stack.maas mini-stack" >>/etc/hosts'     
lxc exec maasctl -- /bin/bash -c 'cat /var/lib/maas/.ssh/id_rsa.pub' >>~/.ssh/authorized_keys        
lxc exec maasctl -- su -l maas /bin/bash -c 'ssh-keyscan -H mini-stack.maas >>~/.ssh/known_hosts'
lxc exec maasctl -- su -l maas /bin/bash -c 'ssh -oStrictHostKeyChecking=accept-new root@mini-stack.maas hostname'
lxc exec maasctl -- su -l maas /bin/bash -c 'virsh -c qemu+ssh://root@mini-stack.maas/system list --all'
````

#### 02. Connect your libvirt provider as a POD in MAAS
````
lxc exec maasctl -- /bin/bash -c 'maas admin pods create type=virsh name=mini-stack.maas power_address=qemu+ssh://root@192.168.1.2/system cpu_over_commit_ratio=10 memory_over_commit_ratio=10'
````

#### 03. Test create new VM in your virsh pod:
```
lxc exec maasctl -- /bin/bash -c 'maas admin pod compose 1 cores=2 memory=2048 "storage=root:32(default)"'
virsh list --all
virsh console $new_vm_id
```

 <!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
