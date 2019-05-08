# Part 5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

-------
#### 00. Source CCIO Profile
````sh
source /etc/ccio/mini-stack/profile 

````
#### 01. Create maas container profile
````sh
lxc profile create maasctl
wget -O- https://git.io/fjtcz 2>/dev/null | bash
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
 2. Click 'skip' through on-screen setup prompts (this was already done via cli)    
 3. Click "Controllers" tab    
 4. Click "maasctl.maas"    
 5. services should all be 'green' excluding dhcp* & ntp*    

#### 04. Reboot and confirm MAAS WebUI & MAAS Region+Rack controller services are all healthy again

-------
## Next sections
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part 0 Host System Prep]: ../0_Host_System_Prep
[Part 1 Single Port Host OVS Network]: ../1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: ../2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: ../3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: ../4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: ../5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: ../6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: ../7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: ../8_OpenStack_Deploy
