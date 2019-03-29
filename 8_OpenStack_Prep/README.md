# Part_8 -- OpenStack Prep
###### Provision OpenStack Deployment Requirements

Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]
- [PART_6 MAAS Connect POD on KVM Provider]
- [PART_7 Juju MAAS Cloud]

![CCIO Hypervisor - OpenStack Prep](https://github.com/KathrynMorgan/mini-stack/blob/master/8_OpenStack_Prep/web/drawio/OpenStack-Prep.svg)

# Instructions:
#### Create New Virtual Machines & Tag as Juju OpenStack Targets
###### 01. Virt-Install new vm's
```
wget -P /root/ https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/8_OpenStack_Prep/aux/virt-inst-stack.sh && chmod +x ~/virt-inst-stack.sh
. ~/virt-inst-stack.sh
```


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
