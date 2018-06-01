###########################################################################################
## How to create an LXD gateway to an OVS network

lxc launch ubuntu:bionic maas-gw
lxc config set maas-gw security.privileged true
lxc network attach maas-net maas-gw eth1 eth1
lxc exec maas-gw bash
apt update && apt upgrade -y && apt install -y isc-dhcp-server network-manager
git clone https://gitlab.com/kat.morgan/lxd-router.git

cat <<EOF >> /etc/netplan/50-cloud-init.yaml
        eth1:
            addresses: [ 172.10.0.4/16 ]
EOF

netplan apply
netplan generate
ip link set eth1 up

ln lxd-router/bin/* /usr/bin/
ln lxd-router/systemd/firewall-up.service /etc/systemd/system
systemctl enable firewall-up
systemctl start firewall-up

###########################################################################################
## OPTIONAL: Set Other Interfaces
vim lxd-router/iptables-enabled/interfaces.conf

## ## TODO:
       Improve ipv4 forwarding via systemd
         # cat /etc/systemd/network/tun0.network
         [Match]
         Name=tun0

         [Network]
         IPForward=ipv4
       Refrences:
         - https://serverfault.com/questions/753977/how-to-properly-permanent-enable-ip-forwarding-in-linux-with-systemd/754723
         - https://github.com/systemd/systemd/blob/a2088fd025deb90839c909829e27eece40f7fce4/NEWS