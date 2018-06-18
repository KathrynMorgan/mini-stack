# CCIO Hypervisor
# PART_3 -- LXD gateway/firwall appliance for 'maas-net' OVS Bridge
Prerequisites:
- [Part_1 Single Port Host Network Configuration]
- [Part_2 LXD On Open vSwitch Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/small-stack/blob/master/3_LXD-Network-Gateway/web/drawio/lxd-gateway.svg)
<a href="https://github.com/KathrynMorgan/small-stack/blob/master/3_LXD-Network-Gateway/web/drawio/lxd-gateway.svg" target="_blank">lxd-on-openvswitch.svg</a>

###### Launch and configure base gateway container
````sh
lxc launch ubuntu:bionic maas-gw01
lxc config set maas-gw01 security.privileged true
lxc network attach physical-net maas-gw01 eth0 eth0
lxc network attach maas-net maas-gw01 eth1 eth1
lxc restart maas-gw01
````

###### Configure Base Firewall/Router iptables
1. Acquire a console <br/>
`lxc exec maas-gw01 bash`
2. Update & Upgrade your container <br/>
`sudo apt update && sudo apt upgrade -y`
3. Install required packages <br/>
`apt install -y isc-dhcp-server network-manager`
4. Clone the lxd-router repo <br/>
`git clone https://gitlab.com/kat.morgan/lxd-router.git`
5. Add the "eth1" interface static IP in your netplan config <br/>
Example:
````sh
cat <<EOF >> /etc/netplan/50-cloud-init.yaml
        eth1:
            addresses: [ 172.10.0.4/16 ]
EOF
````
6. Apply configuration <br/>
`netplan apply && netplan generate`
7. Raise eth1 <br/>
`ip link set eth1 up`
8. Link executables <br/>
`ln lxd-router/bin/* /usr/bin/``
9. Link systemd unit <br/>
`ln lxd-router/systemd/firewall-up.service /etc/systemd/system`
10. Start & Enable the new systemd unit <br/>
`systemctl start firewall-up && systemctl enable firewall-up`

#### OPTIONAL:
Define other interfaces in `/root/lxd-router/iptables-enabled/interfaces.conf`

#### TODO:

       Improve ipv4 forwarding via systemd
         # cat /etc/systemd/network/tun0.network
         [Match]
         Name=tun0

         [Network]
         IPForward=ipv4
       Refrences:
         - https://serverfault.com/questions/753977/how-to-properly-permanent-enable-ip-forwarding-in-linux-with-systemd/754723
         - https://github.com/systemd/systemd/blob/a2088fd025deb90839c909829e27eece40f7fce4/NEWS


 <!-- Markdown link & img dfn's -->
[Part_1 Single Port Host Network Configuration]: https://github.com/KathrynMorgan/small-stack/blob/master/1_Bare-Metal_Single-Port-OVS-Hypervisor/
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/2_Bare-Metal_LXD-On-OVS
[Part_3 Libvirtd/KVM/QEMU On Open vSwitch bridge]: https://github.com/KathrynMorgan/small-stack/tree/master/3_Bare-Metal_KVM-On-OVS
[Part_4 MAAS Server On dedicated MAAS Open vSwitch Network]: https://github.com/KathrynMorgan/small-stack/tree/master/4_Bare-Metal_MAAS-On-OVS_Simple
[Part_5 MAAS POD Configuration on Libvirt provider]: https://github.com/KathrynMorgan/small-stack/tree/master/5_Bare-Metal_MAAS-POD_LibvirtD-Provider
