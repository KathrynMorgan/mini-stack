# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

## Instructions:
#### 01. Create maas container profile
````
lxc profile create maasctl
wget -O /tmp/profile-maasctl.yaml https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/aux/profile-maasctl.yaml
lxc profile edit maasctl </tmp/profile-maasctl.yaml 
````

#### 02. Create 'maasctl' Ubuntu Bionic LXD Container
````
lxc launch ubuntu:bionic maasctl -p maasctl
lxc exec maasctl -- tail -f /var/log/cloud-init-output.log
````

#### 03. Login to WebUI && Complete Setup
Browse to your maas WebUI in a browser at: http://<gateway-ip>:5240/MAAS

#### 04. Walk through on-screen setup:
 1. Confirm region name (EG: 'lab')
 2. Set DNS Forwarder   (EG: '192.168.1.1 8.8.8.8')
 3. Leave Ubuntu Archive* && apt/http proxy server as default for now
 4. Leave Image selection to default options for now
 5. Click 'Continue'
 6. Import SSH key(s) for user
 7. click 'Go to dashboard'

#### 05. Confirm region and rack controller(s) show healthy
 1. Click "Controllers" tab
 2. click "maasctl.maas"
 3. services should all be 'green' excluding dhcp* & ntp*

#### Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy
ProTip: Be sure to enable dhcp or a dhcp reservantion on the networking page .... << TODO Write Out Instructions    

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
