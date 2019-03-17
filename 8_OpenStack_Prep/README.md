# Part_8 -- OpenStack Prep
###### Provision OpenStack Deployment Requirements

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]
- [Part_6 MAAS POD Configuration on Libvirt Provider]

![CCIO Hypervisor - OpenStack Prep](https://github.com/KathrynMorgan/mini-stack/blob/master/8_Juju_MAAS_Cloud/web/drawio/juju_maas_cloud_controller.svg)

# Instructions:
#### Create New Virtual Machines & Tag as Juju OpenStack Targets
###### 01. Virt-Install new vm's
```
lxc exec cloudctl -- /bin/bash -c "cat /home/ubuntu/.ssh/id_rsa.pub" >>/root/.ssh/authorized_keys
```
```
wget -O- https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/8_OpenStack_Prep/aux/virt-inst-stack.sh | bash -x
```


<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part_6 MAAS POD Configuration on Libvirt Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
