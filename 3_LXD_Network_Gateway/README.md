# PART_3 -- LXD Gateway & Firwall for Open vSwitch Network Isolation
###### Create a sandboxed network environment with OpenVSwitch and an LXD Gateway using the [Unofficial OpenWRT LXD Project](https://github.com/containercraft/openwrt-lxd)

-------
Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/3_LXD_Network_Gateway/web/drawio/lxd-gateway.svg)

-------
#### 01. Add the BCIO Remote LXD Image Repo
````sh
lxc remote add bcio https://images.braincraft.io --public --accept-certificate
````
#### 02. Write OVS bridge 'lan' Networkd Configuration
````sh
cat <<EOF >/etc/systemd/network/lan.network                                                    
[Match]
Name=lan

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````
#### 03. Write OVS 'lan' bridge port 'mgmt1' netplan config
````sh
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
        addresses: [10.10.0.10,8.8.8.8]
EOF
````
#### 04. Build Bridge & mgmt1 interface
````sh
ovs-vsctl \
  add-br lan -- \
  add-port lan mgmt1 -- \
  set interface mgmt1 type=internal -- \
  set interface mgmt1 mac="$(echo "$HOSTNAME lan mgmt1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')"
ovs-vsctl show
````
#### 05. Create OpenWRT LXD Profile
````sh
lxc profile copy original openwrt
lxc profile set openwrt security.privileged true
lxc profile device set openwrt eth0 parent wan
lxc profile device add openwrt eth1 nic nictype=bridged parent=lan
````
#### 06. Launch Gateway
````sh
lxc launch bcio:openwrt gateway -p openwrt
````
#### 07. Apply CCIO Configuration + http squid cache proxy
###### WARNING: DO NOT LEAVE EXTERNAL WEBUI ENABLED ON UNTRUSTED NETWORKS
````sh
lxc exec gateway -- /bin/bash -c "sed -i 's/192.168.1/10.10.0/g' /etc/config/network" && lxc stop gateway && sleep 3 && lxc start gateway
lxc exec gateway -- /bin/bash -c "wget -O- https://git.io/fjtcf | bash" && sleep 8 && lxc start gateway
````
#### 08. Test OpenWRT WebUI Login on 'WAN' IP Address    
###### CREDENTIALS: [USER:PASS] [root:admin] -- [http://gateway_wan_ip_addr:8080/](http://gateway_wan_ip_addr:8080/)

#### 09. Remove mgmt0 default route && Reload host network configuration
````sh
sed -i -e :a -e '$d;N;2,4ba' -e 'P;D' /etc/netplan/80-mgmt0.yaml
systemctl restart systemd-networkd.service && netplan apply --debug
````
#### 10. Copy LXD 'default' profile to 'wan'
````sh
lxc profile copy default wan
````
#### 11. Set LXD 'default' profile to use the 'lan' network
````sh
lxc profile device set default eth0 parent lan
````

-------
#### OPTIONAL: Enable your new 'lan' network on a physical port. (EG: eth1)
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

-------
## Next sections
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]
- [PART_6 MAAS Connect POD on KVM Provider]
- [PART_7 Juju MAAS Cloud]
- [PART_8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part_0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/0_Host_System_Prep
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[PART_6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[PART_7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[PART_8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Prep
