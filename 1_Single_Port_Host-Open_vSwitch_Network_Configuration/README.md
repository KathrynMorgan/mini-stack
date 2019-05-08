# Part 1 -- Single Port Host Open vSwitch Network Configuration
#### Provision a host virtual entry network viable for cloud scale emulation and testing.
WARNING: Exercise caution when performing this procedure remotely as this may cause loss of connectivity.    

-------
## Prerequisites:
- [Part 0 Host System Prep]

>
> Overview of Steps:
> - Install required packages
> - Enable Open vSwitch Service & Confirm running status
> - Create base OVS Bridge for interfacing with local physical network
> - Create a virtual host ethernet port on the 'wan' bridge
> - Impliment 'systemd-networkd' workaround RE: [BUG: 1728134]

![CCIO_Hypervisor-mini_Stack_Diagram](https://github.com/KathrynMorgan/mini-stack/blob/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration/web/drawio/single-port-ovs-host.svg)

-------
#### 01. Update system && Install Packages
```sh
apt install -y openvswitch-switch
```
#### 02. Write physical network ingress port Networkd Config [EG: 'eth0']
NOTE: export name of nic device your primary host network traffic will traverse (EG: 'eth0' in this example)
```sh
export wan_NIC="eth0"
```
```sh
cat <<EOF >/etc/systemd/network/${wan_NIC}.network                                                    
[Match]
Name=${wan_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF

```
#### 03. Write OVS  Bridge 'wan' Networkd Config
```sh
cat <<EOF >/etc/systemd/network/wan.network                                                    
[Match]
Name=wan

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF

```

#### 04. Disable original Netplan Config & Write mgmt0 interface netplan config
````sh
for yaml in $(ls /etc/netplan/); do sed -i 's/^/#/g' /etc/netplan/${yaml}; done
````
````sh
cat <<EOF >/etc/netplan/80-mgmt0.yaml
# For more configuration examples, see: https://netplan.io/examples                                                   
# OVS 'wan' Bridge Port 'mgmt0' Configuration
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt0:
      optional: true
      addresses:
        - $(ip a s ${wan_NIC} | awk '/inet /{print $2}' | head -n 1)
      gateway4: $(ip r | awk '/default /{print $3}' | head -n 1)
      nameservers:
        addresses: 
          - $(systemd-resolve --status | grep "DNS Server" | awk '{print $3}')
EOF

````
#### 05. Build OVS Bridge, mgmt0 port, and apply configuration
````sh
cat <<EOF >/tmp/net_restart.sh
net_restart () {
ovs-vsctl \
  add-br wan -- \
  add-port wan ${wan_NIC} -- \
  add-port wan mgmt0 -- \
  set interface mgmt0 type=internal -- \
  set interface mgmt0 mac="$(echo "${HOSTNAME} wan mgmt0" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')"
systemctl restart systemd-networkd.service && netplan apply --debug
ovs-vsctl show
}
net_restart
EOF

````
````sh
source /tmp/net_restart.sh 

````
#### 06. Add OVS Orphan Port Cleaning Utility
NOTE: Use command `ovs-clear` to remove orphaned 'not found' ports as needed
````sh
wget -O /usr/bin/ovs-clear https://git.io/fjtnB && chmod +x /usr/bin/ovs-clear 

````
-------
#### CHEAT: Useful Commands for troubleshooting
````sh
ip r
ip a s
ovs-vsctl show
systemd-resolve --status 

````

## Next sections
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[BUG: 1728134]: https://bugs.launchpad.net/netplan/+bug/1728134
[Part 0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/0_Host_System_Prep
[Part 1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Deploy
