# Part_7 -- Build MAAS Cloud Controller
###### Create a Juju Cloud on MAAS & Bootstrap the Juju Controller

## Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]
- [PART_6 MAAS Connect POD on KVM Provider]

![CCIO Hypervisor - JujuCTL Cloud Controller](https://github.com/KathrynMorgan/mini-stack/blob/master/7_Juju_MAAS_Cloud/web/drawio/juju_maas_cloud_controller.svg)

#### Instructions
`wget -O /tmp/lxd_profile_cloudctl.yaml https://git.io/fjLpl`    
`export maasctl_api_key=$(lxc exec maasctl -- maas-region apikey --username=admin)`                                                      
`lxc profile create cloudctl`    
`lxc profile edit cloudctl < <(sed "s/maasctl_api_key/${maasctl_api_key}/g" /tmp/lxd_profile_cloudctl.yaml)`    
`lxc launch ubuntu:bionic cloudctl -p cloudctl`    


`lxc exec cloudctl -- /bin/bash -c "cat /home/ubuntu/.ssh/id_rsa.pub" >>/root/.ssh/authorized_keys`     
`lxc ubuntu cloudctl`    
`juju add-cloud maasctl ~/.juju/maasctl.yaml`     
`juju add-credential maasctl -f ~/.juju/credentials-maasctl.yaml`    
`juju show-cloud maasctl`    

#### Bootstrap a Juju controller
## PROTIP  
Remember, if you followed previous guides, you can go to the
libvirt host and use 'virsh list' and 'virsh console' to monitor
the vm's console during bootstrap <br/>
`juju bootstrap --bootstrap-series=bionic --config bootstrap-timeout=1800 --constraints "cores=4 mem=4G" maasctl jujuctl`    

#### Test adding new machines on your cloud
  01. Add 2 Libvirt guests configured with 2 cores and 2GB RAM
`juju add-machine -n 2 --constraints "cores=2 mem=2G"`     
  02. Add 2 new lxd containers
`juju add-machine lxd:0`    
`juju add-machine lxd:1`    

#### Find juju WebGUI
`juju gui`    

#### Launch your first juju charm
`juju deploy -n 1 haproxy`     

## Continue to the next section
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
