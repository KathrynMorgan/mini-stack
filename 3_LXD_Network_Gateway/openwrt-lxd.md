# OpenWRT LXD Gateway on bare Ubuntu OS

#### 1. Install Packages
````sh
apt update && apt upgrade -y && apt dist-upgrade -y
apt install -y openvswitch-switch ifupdown lxd htop
````

#### 2. Eliminate netplan due to ovs support (BUG: 1728134)
````sh
sed 's/^/#/g' /etc/netplan/*.yaml
````

#### 3. Create default "interfaces" file
````sh
cat <<EOF >>/etc/network/interfaces
# /etc/network/interfaces
auto lo                                                                                   
iface lo inet loopback

# Run interfaces.d config files
source /etc/network/interfaces.d/*.cfg
EOF
````

#### 4. Create wan bridge interfaces file
````sh
cat <<EOF >>/etc/network/interfaces.d/wan.cfg
allow-hotplug wan
iface wan inet manual
EOF
````

#### 5. Create ens3 interfaces file
````sh
cat <<EOF >>/etc/network/interfaces.d/ens3.cfg
# Raise ens3 on ovs-br 'wan' with no IP
allow-hotplug ens3
iface ens3 inet manual
EOF
````

#### 6. Create lan bridge interfaces file
````sh
cat <<EOF >>/etc/network/interfaces.d/lan.cfg
allow-hotplug lan
iface lan inet manual
EOF
````

#### 7. Generate unique MAC address for mgmt0 iface
````sh
export HWADDRESS=$(echo "$HOSTNAME lan mgmt0" \
| md5sum \
| sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
````

#### 8. Create Bridges && add ports
````sh
ovs-vsctl add-br wan \
  -- add-port wan ens3 \
  -- add-br lan \
  -- add-port lan mgmt0 \
  -- set interface mgmt0 type=internal \
  -- set interface mgmt0 mac="$HWADDRESS" \
````


####  9. Initialize LXD
````sh
cat <<EOF | lxd init --preseed
config:
  images.auto_update_interval: "0"
cluster: null
networks: []
storage_pools:
- config:
    size: 15GB
  description: ""
  name: default
  driver: btrfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: macvlan
      parent: lan
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
EOF
````

#### 10. Add bcio remote
````sh
lxc remote add bcio https://images.braincraft.io --public --accept-certificate
````

#### 11. Initialize Gateway as privileged container
````sh
lxc init bcio:openwrt gateway
lxc config set gateway security.privileged true
````

#### 12. Attach Interfaces
  - eth1 = WAN Bridge
  - eth0 = LAN Bridge
````sh
lxc network attach wan gateway eth1 eth1
lxc network attach lan gateway eth0 eth0
````

#### 13. Start gateway & set gateway config options
````sh
lxc start gateway
lxc exec gateway -- /bin/ash -c "uci set network.lan.ipaddr='192.168.1.1'"
lxc exec gateway -- /bin/ash -c "uci set network.lan.netmask='255.255.255.0'"
lxc exec gateway -- /bin/ash -c "uci set network.lan.proto='static'"
lxc exec gateway -- /bin/ash -c "uci commit"
````

#### 14. Create mgmt0 interfaces file
````sh
cat <<EOF >>/etc/network/interfaces.d/mgmt0.cfg
# Raise host mgmt0 iface on ovs-br 'lan' with no IP
allow-hotplug mgmt0
iface mgmt0 inet static
  address 192.168.1.5
  gateway 192.168.1.1
  netmask 255.255.255.0
  nameservers 192.168.1.1
  mtu 1500
EOF
````

#### 15. Reboot host system & inherit!
````sh
reboot
````

#### Find your WebUI in a lan side browser @ 192.168.1.1 username:password admin:password
#### TODO: Fix https://github.com/mikma/lxd-openwrt/issues/3 & rebuild/publish image
