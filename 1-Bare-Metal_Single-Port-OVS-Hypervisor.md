###########################################################################################
## How to get an internal ovs bridge on lan with a clean install of Bionic and only one NIC
## NOTE: netplan does not currently support raising interfaces without ip addresses
##       Until the issue is resolved we will use ifupdown
## Run as root

###########################################################################################
## Update system
  apt update \
    && apt upgrade -y \
    && apt dist-upgrade -y \
    && apt autoremove -y

###########################################################################################
## Install Packages
  apt install --install-recommends -y openvswitch-switch-dpdk   ## On Intel Systems
  apt install --install-recommends -y openvswitch-switch        ## On Other Systems 
  apt install -y ifupdown                                       ## RE: Netplan BUG #1728134

###########################################################################################
## Confirm OVS Running
  systemctl status openvswitch-switch
  ovs-vsctl show

###########################################################################################
## Create OVS Bridge
  ovs-vsctl add-br physical-net

###########################################################################################
## Create host virtual interface on bridge
  ovs-vsctl add-port physical-net mgmt0 \
    -- set interface mgmt0 type=internal
  ovs-vsctl show
###########################################################################################
## Edit /etc/netplan/50-cloud-init.yaml
***
Comment out or remove lines for ens3 like the following
***
network:
    ethernets:
#       ens3:
#           addresses: []
#           dhcp4: true
#           optional: true
    version: 2

###########################################################################################
## Edit /etc/network/interfaces
# Loopback Network Interface
auto lo
iface lo inet loopback

# physical-net OVS Bridge
allow-hotplug physical-net
iface physical-net inet manual

# Bridge Port to physical-net OVS Bridge
allow-hotplug ens3
iface ens3 inet manual

# host routable interface mgmt0
allow-hotplug mgmt0
iface mgmt0 inet static
  address 10.10.10.150
  netmask 255.255.255.0
  network 10.10.10.0
  gateway 10.10.10.10
  mtu 1500

###########################################################################################
## Configure Name Resolution
vim /etc/systemd/resolved.conf
***
[Resolve]
DNS=8.8.8.8
***

###########################################################################################
## Attach bridge to LAN
ovs-vsctl add-port physical-net ens3

Reboot & Inherit