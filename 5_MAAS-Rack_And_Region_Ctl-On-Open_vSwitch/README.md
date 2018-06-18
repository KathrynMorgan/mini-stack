# Part_5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network
Prerequisites:
- [Part_1 Single Port Host Network Configuration]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Network Gateway]
- [Part_4 KVM On Open vSwitch]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](https://github.com/KathrynMorgan/small-stack/blob/master/5_MAAS-Rack_And_Region-Ctl-On_Open_vSwitch/web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

## Instructions:
#### 1. Create maas-net OVS bridge via LXD commands
````sh
lxc network create maas-net \
  -c bridge.driver=openvswitch \
  -c ipv4.address=none \
  -c ipv6.address=none \
  -c ipv4.nat=false \
  -c ipv6.nat false
````
#### 2. Write 'maas' network json
````sh
cat <<EOF >>virsh-net-maas.json
<network>
  <name>maas</name>
  <forward mode='bridge'/>
  <bridge name='maas-net' />
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
Note, due to UID/GID mappings, only one MAAS LXD Container is recommended per host.
<br/>While workarounds are an option. I recommend building MAAS in virtual machines rather than containers if more than one MAAS node is expected to be built on a host.
>#### [OPTION A] Using LXD:
>>###### Create Container (assumes default network = 'physical-net')
>>   1. `lxc launch ubuntu:bionic maasctl`
>>###### Enable privileged container TODO: test w/o sec escalation!!!
>>   2. `lxc config set maasctl security.privileged true`
>>###### Attach 2nd Network to Container
>>   3. `lxc network attach maas-net maasctl eth1 eth1`
>>###### Aquire console in container
>>   4. `lxc exec maasctl bash`
>
>#### [OPTION B] Using the Libvirtd+ISO Installer:
>>###### Connect virt-manager to Host QEMU via ssh
>>   0. Use virt-manager to attach to your host's QEMU
>>###### Download ISO for new VM
>>   1. `sudo wget -O /var/lib/libvirt/images/ubuntu-18.04-live-server-amd64.iso http://releases.ubuntu.com/18.04/ubuntu-18.04-live-server-amd64.iso`
>>###### Build new Ubuntu Bionic VM
>>   2. Use virt-manager to create a new vm 'maasctl' using your newly downloaded bionic iso
>>###### Attach 2nd Network to VM
>>   3. Connect 2nd ethernet port to VM on 'maas-net' bridge
>>###### Aquire console in VM
>>   4. ssh to new maasctl

#### 5. Configure 2nd NIC for your future maas network (Example config included)
````
sudo vim /etc/netplan/50-cloud-init.yaml
````
Example:
````sh
network:
    version: 2
    ethernets:
        eth0:         #### physical-net interface
            dhcp4: true
        eth1:         #### maas-net interface
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

#### 9. Configure MAAS Region Controller to use your 'maas-net' bridge IP for PXE
Example: `172.10.0.1`
````sh
sudo dpkg-reconfigure maas-region-controller
````

#### 10. Configure MAAS Rack Controller to use your 'maas-net' bridge IP for API etc.
Example: http://172.10.0.1:5240/MAAS
````sh
sudo dpkg-reconfigure maas-rack-controller
````
#### 11. Login to WebUI && Complete Setup
Example: http://172.10.0.1:5240/MAAS <br/>
Browse to your maas WebUI in a browser at: http://[physical-net_IP]:5240/MAAS

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

#### 14. Finish 'maas-net' configuration
 1. Click 'Subnets'
 2. Identify the 'maas-net' bridge network
 -- IE: '172.10.0.0/16' in this case
 3. For the 'maas-net' network click 'untagged' 'vlan' column engry
 4. Click 'Take action' Dropdown Menu (top right)
 5. Click 'Provide DHCP'
 6. Ensure start/end ranges & gateway IP are reasonable
 -- NOTE: Gateway IP should match the 'maasctl' 'maas-net' interface
 -- IE:   In this Example: '172.10.0.1'
 7. Click 'Profide DHCP'

#### Reboot and confirm MAAS WebUI & MAAS Region+Rack controller are all healthy

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host Network Configuration]: https://github.com/KathrynMorgan/small-stack/blob/master/1_Bare-Metal_Single-Port-OVS-Hypervisor/
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/2_Bare-Metal_LXD-On-OVS
[Part_3 LXD Network Gateway]: https://github.com/KathrynMorgan/small-stack/tree/master/3_LXD-Network-Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/small-stack/tree/master/4_Bare-Metal_KVM-On-Open-vSwitch
