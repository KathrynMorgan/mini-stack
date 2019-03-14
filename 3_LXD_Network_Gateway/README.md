# PART_3 -- LXD Gateway & Firwall for Open vSwitch Network Isolation
###### Create a sandbox network environment using OVS Network(s) behind an OpenWRT Gateway using the [Unofficial OpenWRT Image Project](https://github.com/containercraft/openwrt-lxd)
Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/3_LXD_Network_Gateway/web/drawio/lxd-gateway.svg)

## Instructions:
#### 1. Add bcio remote
````sh
lxc remote add bcio https://images.braincraft.io --public --accept-certificate
````

#### 2. Add mgmt1 netplan config
````
cat <<EOF > /etc/netplan/80-mgmt1.yaml
# Configure mgmt1 on 'lan' bridge
# For more configuration examples, see: https://netplan.io/examples
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt1:
      optional: true
      addresses:
        - 10.10.0.2/24
      gateway4: 10.10.0.1
      nameservers:
        search: [maas]
        addresses: [10.10.0.1]
EOF
````

#### 3. Write systemd-networkd config to raise 'lan' bridge

````
cat <<EOF > /etc/systemd/network/lan.network                                                    
[Match]
Name=lan

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````

#### 5. Build Bridge
````
ovs-vsctl \
  add-br lan -- \
  add-port lan mgmt1 -- \
  set interface mgmt1 type=internal -- \
  set interface mgmt1 mac="$(echo "$HOSTNAME lan mgmt1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')"
ovs-vsctl show
````

#### 6. Create OpenWRT LXD Profile
````sh
lxc profile copy original openwrt
lxc profile set openwrt security.privileged true
lxc profile device set openwrt eth0 parent wan
lxc profile device add openwrt eth1 nic nictype=bridged parent=lan
````

#### 8. Launch Gateway
````sh
lxc launch bcio:openwrt gateway -p openwrt
````

#### 9. Set openwrt 'lan' network
```
lxc exec gateway -- sed -i 's/192.168.1.1/10.10.0.1/g' /etc/config/network && lxc restart gateway
```

#### 10. Enable OpenWRT WebUI on 'WAN'    
###### CREDENTIALS: [USER:PASS] [root:admin]     
###### WARNING: DO NOT ENABLE ON UNTRUSTED NETWORKS
````sh
lxc exec gateway ash

````

#### 10. Remove mgmt0 default route && Reload host network configuration
````sh
sed -i -e :a -e '$d;N;2,3ba' -e 'P;D' /etc/netplan/80-mgmt0.yaml
systemctl restart systemd-networkd.service && netplan apply --debug
````

#### 11. Copy LXD 'default' profile to 'wan'
````sh
lxc profile copy default wan
````

#### 12. Set LXD 'default' profile to use the 'lan' network
````sh
lxc profile device set default eth0 parent lan
````

#### ProTip: Enable your new 'lan' network on a physical port. (Example: eth1)
````sh
export lan_NIC="eth1"
````
````sh
cat <<EOF > /etc/systemd/network/${lan_NIC}.network                                                    
[Match]
Name=${lan_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````
````sh
ovs-vsctl add-port lan ${lan_NIC}
systemctl restart systemd-networkd.service
````

 <!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
