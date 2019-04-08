# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

-------
Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

-------
#### 01. Create maas container profile
````sh
wget -O /tmp/lxd-profile-maasctl.yaml https://git.io/fjtcz
lxc profile create maasctl
lxc profile edit maasctl </tmp/lxd-profile-maasctl.yaml
````
#### 02. Create 'maasctl' Ubuntu Bionic LXD Container
NOTE: Build time is dependent on hardware & network specs, monitor logs until build is complete
````sh
lxc launch ubuntu:bionic maasctl -p maasctl
lxc exec maasctl -- tail -f /var/log/cloud-init-output.log
````
#### 03. Login to WebUI && Confirm region and rack controller(s) show healthy
NOTE: dhcp services are dependent on completion of full image sync. Please wait till image download & sync has finished.
 1. Browse to your maas WebUI @ [http://openwrt-gateway-pub-ip:5240/MAAS](http://{openwrt-gateway-pub-ip}:5240/MAAS)
 2. click 'skip' through on-screen setup prompts (this was already done via cli)    
 3. Click "Controllers" tab    
 4. click "maasctl.maas"    
 5. services should all be 'green' excluding dhcp* & ntp*    

#### 04. Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy

-------
## Next sections
- [PART_6 MAAS Connect POD on KVM Provider]
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
