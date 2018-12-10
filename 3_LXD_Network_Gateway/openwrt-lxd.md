#### 00. Add bcio remote
````sh
lxc remote add bcio https://images.braincraft.io --public --accept-certificate
````

#### 0. Add mgmt1 netplan config
````
cat <<EOF > /etc/netplan/80-mgmt1.yaml
# Configure mgmt1 on 'lan' bridge
# For more configuration examples, see: https://netplan.io/examples
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt1:
      dhcp4: true
EOF
````

#### 5. Write systemd-networkd config to raise 'lan' bridge

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

#### 09. Generate unique MAC address for mgmt1 iface
````sh
export HWADDRESS=$(echo "$HOSTNAME lan mgmt1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
````

#### 10. Create LAN Bridge && add LAN Host MGMT0 Virtual Interface to Bridge
````sh
ovs-vsctl add-br lan -- add-port lan mgmt1 -- set interface mgmt1 type=internal -- set interface mgmt0 mac="$HWADDRESS"
````

#### 12. Create OpenWRT LXD Profile
````sh
lxc profile copy default openwrt
lxc profile set openwrt security.privileged true
lxc profile device set openwrt eth0 parent wan
lxc profile device add openwrt eth1 nic nictype=bridged parent=lan
````

#### 13. Launch Gateway
````sh
lxc launch bcio:openwrt gateway -p openwrt
````

#### 14. Watch container for eth0 & br-lan ip initialization    
###### We are expecting to acquire:    
###### 1. An IP from your local network on gateway container's 'eth0' interface
###### 2. An IP of '192.168.1.1' on gateway container's 'br-lan' interface
###### "ctrl + c" to exit "watch" cmd    
````sh
watch -c lxc list
````

#### 00. Acquire dhcp lease on interface 'mgmt1' from the new gateway
````sh
netplan apply --debug
````

=================================================================================
#### Find your WebUI in a lan side browser @ 192.168.1.1 
###### Username: root 
###### Password: admin
