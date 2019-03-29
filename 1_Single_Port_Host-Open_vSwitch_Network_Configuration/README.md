# Part 1 -- Single Port Host Open vSwitch Network Configuration
#### Provision a host virtual entry network viable for cloud scale emulation and testing.

## Prerequisites:
- [Part_0 Host System Prep]
 
WARNING: Exercise caution when performing this proceedure remotely as this may cause loss of connectivity.    

>
> Overview of Steps:
> - Install required packages
> - Enable Open vSwitch Service & Confirm running status
> - Create base OVS Bridge for interfacing with local physical network
> - Create a virtual host ethernet port on the 'wan' bridge
> - Impliment 'systemd-networkd' workaround RE: [BUG: 1728134]

![CCIO_Hypervisor-mini_Stack_Diagram](https://github.com/KathrynMorgan/mini-stack/blob/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration/web/drawio/single-port-ovs-host.svg)

## Instructions:
#### 1. Update system && Install Packages
```
apt update && apt install -y openvswitch-switch
```

#### 2. Create OVS  'wan'  Bridge Networkd Config
````
cat <<EOF > /etc/systemd/network/wan.network                                                    
[Match]
Name=wan

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````

#### 3. Write Networkd config for physical network access: [EG: 'eth0']
```sh
export wan_NIC="eth0"
````
````
cat <<EOF > /etc/systemd/network/${wan_NIC}.network                                                    
[Match]
Name=${wan_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````

#### 4. Disable original Netplan Config & Write mgmt0 interface netplan config
````sh
for i in $( ls /etc/netplan/  ); do sed -i 's/^/#/g' /etc/netplan/$i ; done
````
````
cat <<EOF > /etc/netplan/80-mgmt0.yaml
# Configure mgmt0 on 'wan' bridge
# For more configuration examples, see: https://netplan.io/examples                                                   
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt0:
      optional: true
      addresses:
        - $(ip a s ${wan_NIC} | awk '/inet /{print $2}')
      gateway4: $(ip r | awk '/default /{print $3}')
      nameservers:
        addresses: [$(ip r | awk '/default /{print $3}')]
EOF
````

#### 5. Apply configuration
````
cat <<EOF >/tmp/net_restart.sh
net_restart () {

ovs-vsctl \
  add-br wan -- \
  add-port wan ${wan_NIC} -- \
  add-port wan mgmt0 -- \
  set interface mgmt0 type=internal -- \
  set interface mgmt0 mac="$(echo "$HOSTNAME wan mgmt0" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')"

systemctl restart systemd-networkd.service && netplan apply --debug

ovs-vsctl show
}
net_restart
EOF
````
````
source /tmp/net_restart.sh 
````

#### 6. Add OVS Orphan Port Cleaning Utility
````sh
wget -O /usr/bin/ovs-clear https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration/aux/ovs-clear && chmod +x /usr/bin/ovs-clear
````

#### PROTIP: Useful Commands
````
ip r
ip a s
ovs-vsctl show
systemd-resolve --status
````

## Next sections
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]
- [PART_6 MAAS Connect POD on KVM Provider]
- [PART_7 Juju MAAS Cloud]
- [PART_8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[BUG: 1728134]: https://bugs.launchpad.net/netplan/+bug/1728134
[Part_0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/0_Host_System_Prep
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[PART_6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[PART_7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[PART_8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Prep
