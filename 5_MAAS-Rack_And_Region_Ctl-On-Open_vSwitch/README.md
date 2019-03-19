# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host Open vSwitch Network Configuration]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

## Instructions:
#### 01. Create maas container profile
````
wget -O /tmp/profile-maasctl.yaml https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/aux/profile-maasctl.yaml
lxc profile create maasctl && lxc profile edit maasctl </tmp/profile-maasctl.yaml
````

#### 02. Create 'maasctl' Ubuntu Bionic LXD Container
````
lxc launch ubuntu:bionic maasctl -p maasctl
lxc exec maasctl -- tail -f /var/log/cloud-init-output.log
````

#### 03. Login to WebUI && Confirm region and rack controller(s) show healthy
 0. Browse to your maas WebUI @ http://{openwrt-gateway-pub-ip}:5240/MAAS
 1. click 'skip' through on-screen setup prompts (this was already done via cli)
 2. Click "Controllers" tab
 3. click "maasctl.maas"
 4. services should all be 'green' excluding dhcp* & ntp*

###### NOTE: dhcp services are dependent on image sync to complete to rack controllers. Be sure to wait till sync has finished and the service has a moment to start.

#### Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy

## Continue to the next section
- [PART_6 MAAS Connect POD on KVM Provider]

<!-- Markdown link & img dfn's -->
[Part_0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_1 Single Port Host Open vSwitch Network Configuration]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[PART_6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[PART_7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[PART_8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Prep
