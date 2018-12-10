# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

## Instructions:
#### 01. Create 'maas' OVS bridge
````sh
ovs-vsctl add-br maas
````

#### 02. Write virsh 'maas' network xml
````sh
cat <<EOF >~/virsh-net-maas.xml
<network>
  <name>maas</name>
  <forward mode='bridge'/>
  <bridge name='maas' />
  <virtualport type='openvswitch'/>
</network>
EOF
````

#### 03. Define & Start virsh 'maas' network
````sh
virsh net-define ~/virsh-net-maas.xml 
virsh net-start maas && virsh net-autostart maas
````

#### 04. Connect 'maas' bridge to gateway
````sh
lxc network attach maas gateway eth2 eth2
````

#### 05. Add interface configuration in OpenWRT Gateway WebUI
TODO: Convert to CLI task in OpenWRT Gateway
IE: http://192.168.1.1/cgi-bin/luci/admin/network/iface_add

#### 06. Create OpenWRT Firewall Gateway Port Forward Rule
Add maas webui rule to OpenWRT Gateway
Forward port 5240 > port 192.168.2.10:80
http://192.168.1.1/cgi-bin/luci/admin/network/firewall/forwards

#### 07. Create maas container profile
````
lxc profile create maasctl
wget -O ~/profile-maasctl.yaml https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/profile-maasctl.yaml
lxc profile edit maasctl <~/profile-maasctl.yaml 
````

#### 08. Create 'maasctl' Ubuntu Bionic LXD Container
````
lxc launch ubuntu:bionic maasctl -p maasctl
lxc exec maasctl bash
````

#### 09. Install MAAS Region+Rack Controller Packages & Dependencies
(Run inside the maasctl container)
````sh
apt update
apt-add-repository ppa:maas/stable -y
apt install -y maas libvirt-bin
virsh net-destroy default
virsh net-undefine default
````

#### 10. Configure MAAS Region Controller to use your 'maas' bridge IP for PXE
(Run inside the maasctl container) 
Example: `192.168.2.10`
````sh
sudo dpkg-reconfigure maas-region-controller
````

#### 11. Configure MAAS Rack Controller to use your 'maas' bridge IP for API etc.
(Run inside the maasctl container) 
Example: http://192.168.2.10:5240/MAAS
````sh
sudo dpkg-reconfigure maas-rack-controller
````

#### 12. Create User & Login
````sh
sudo maas init
````
EXAMPLE:
````
Create first admin account
Username: admin
Password:
Again:
Email: admin@localhost
Import SSH keys [] (lp:user-id or gh:user-id): lp:$USER
````

#### 13. Login to WebUI && Complete Setup
Browse to your maas WebUI in a browser at: http://<gateway-ip>:5240/MAAS

#### 14. Walk through on-screen setup:
 1. Confirm region name (EG: 'lab.maas')
 2. Set DNS Forwarder   (EG: '192.168.2.1 8.8.8.8')
 3. Leave Ubuntu Archive* && apt/http proxy server as default for now
 4. Leave Image selection to default options for now
 5. Click 'Continue'
 6. Confirm SSH key(s) are imported for user
 7. click 'Go to dashboard'

#### 15. Confirm region and rack controller(s) show healthy
 1. Click "Controllers" tab
 2. click "maasctl.maas"
 3. services should all be 'green' excluding dhcp* & ntp*

#### 16. Finish 'maas' configuration
 1. Click 'Subnets'
 2. Identify the 'maas' bridge network
 -- IE: '192.168.2.0/24'
 3. For the 'maas' network click 'untagged' 'vlan' column engry
 4. Click 'Take action' Dropdown Menu (top right)
 5. Click 'Provide DHCP'
 6. Ensure start/end ranges & gateway IP are reasonable
 7. Click 'Profide DHCP'

#### Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
