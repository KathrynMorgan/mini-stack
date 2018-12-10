# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

## Instructions:
#### 1. Create 'maas' OVS bridge
````sh
ovs-vsctl add-br maas
````

#### 2. Write 'maas' network json
````sh
cat <<EOF >>virsh-net-maas.json
<network>
  <name>maas</name>
  <forward mode='bridge'/>
  <bridge name='maas' />
  <virtualport type='openvswitch'/>
</network>
EOF
````

#### 3. Create & Start virsh 'maas' network
````sh
virsh net-define virsh-maas.network
virsh net-start maas
virsh net-autostart maas
virsh net-list
````

#### 4. Create an Ubuntu Bionic server 'maasctl'
>#### Using LXD:
>>###### Create Container (assumes default network = 'wan')
>>   1. `lxc launch ubuntu:bionic maasctl`
>>###### Enable privileged container TODO: test w/o sec escalation!!!
>>   2. `lxc config set maasctl security.privileged true`
>>###### Attach 2nd Network to Container
>>   3. `lxc network attach maas maasctl eth1 eth1`
>>###### Aquire console in container
>>   4. `lxc exec maasctl bash`

#### 5. Configure 2nd NIC for your future maas network (Example config included)
````
sudo vim /etc/netplan/50-cloud-init.yaml
````
Example:
````sh
network:
  version: 2
  ethernets:
    eth0:          #### wan interface
      dhcp4: true
    eth1:          #### maas interface
      addresses:
        - 172.10.0.1/16
````
````
sudo netplan apply && netplan generate
sudo reboot
````
#### 6. Install MAAS Region+Rack Controller Packages & Dependencies
````sh
sudo apt update
sudo apt-add-repository ppa:maas/stable -y
sudo apt install -y maas libvirt-bin
````
#### 7. Remove the auto-created libvirt bridge
````sh
sudo virsh net-destroy default
sudo virsh net-undefine default
````
#### 8. Create User & Login
````sh
sudo maas init
````

#### 9. Configure MAAS Region Controller to use your 'maas' bridge IP for PXE
Example: `172.10.0.1`
````sh
sudo dpkg-reconfigure maas-region-controller
````

#### 10. Configure MAAS Rack Controller to use your 'maas' bridge IP for API etc.
Example: http://172.10.0.1:5240/MAAS
````sh
sudo dpkg-reconfigure maas-rack-controller
````
#### 11. Login to WebUI && Complete Setup
Example: http://172.10.0.1:5240/MAAS <br/>
Browse to your maas WebUI in a browser at: http://[wan_IP]:5240/MAAS

#### 12. Walk through on-screen setup:
 1. Confirm region name (I use braincraft.io)
 2. Set DNS Forwarder   (I use 8.8.8.8 etc.)
 3. Leave Ubuntu Archive* && apt/http proxy server as default for now
 4. Leave Image selection to default options for now
 5. Click 'Continue'
 6. Confirm SSH key(s) are imported for user
 7. click 'Go to dashboard'

#### 13. Confirm region and rack controller(s) show healthy
 1. Click "Controllers" tab
 2. click "maasctl.maas"
 3. services should all be 'green' excluding dhcp* & ntp*

#### 14. Finish 'maas' configuration
 1. Click 'Subnets'
 2. Identify the 'maas' bridge network
 -- IE: '172.10.0.0/16' in this case
 3. For the 'maas' network click 'untagged' 'vlan' column engry
 4. Click 'Take action' Dropdown Menu (top right)
 5. Click 'Provide DHCP'
 6. Ensure start/end ranges & gateway IP are reasonable
 -- NOTE: Gateway IP should match the 'maasctl' 'maas' interface
 -- IE:   In this Example: '172.10.0.1'
 7. Click 'Profide DHCP'

#### Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
