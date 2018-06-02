# CCIO Hypervisor
# Part 1 -- Single Port Host Configuration
#### Provision a host network viable for cloud scale emulation and testing.
 NOTE:  Netplan does not support raising interfaces without ip addresses.
 Until the issue is resolved we will use ifupdown as a workaround.
>
> Overview of Steps:
> - Install required packages
> - Enable OpenVSwitch Service & Confirm running status
> - Create a base 'physical-net' layer OVS Bridge
> - Create a 'virtual' host ethernet port on the 'phyisical-net' bridge
> - Impliment 'ifupdown' workaround RE: [BUG#1728134]
> - Write Network Configuration

#### 1. Update system
```
apt update \
  && apt upgrade -y \
  && apt dist-upgrade -y \
  && apt autoremove -y
```
#### 2. Install Packages
```
apt install --install-recommends -y openvswitch-switch-dpdk   ## On Intel Systems
apt install --install-recommends -y openvswitch-switch        ## On Other Systems
apt install -y ifupdown                                       ## BUG: [BUG-1728134]
```
#### 3. Confirm OVS Running
```
systemctl status openvswitch-switch
ovs-vsctl show
```
#### 4. Create OVS  'physical-net'  Bridge
```
ovs-vsctl add-br physical-net
```

#### 5. Create host virtual interface on bridge
```
ovs-vsctl add-port physical-net mgmt0 \
  -- set interface mgmt0 type=internal
ovs-vsctl show
```
#### 6. Workaround NetPlan + OpenVSwitch [BUG: 1728134]
> ###### 6.a Comment out all netplan config files
```
sed 's/^/#/g' /etc/netplan/50-cloud-init.yaml
```

> ###### 6.b Configure ifupdown script
````
vim /etc/network/interfaces
````
> Example:
````
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
  network 10.10.10.0
  gateway 10.10.10.10
  netmask 255.255.255.0
  mtu 1500
````
> ###### 6.c Configure preferred DNS Servers:
````
vim /etc/systemd/resolved.conf
````
> Example:
````
[Resolve]
DNS=8.8.8.8
````
#### 7. Attach bridge to LAN
````
ovs-vsctl add-port physical-net ens3
````

# Reboot & Inherit !!

<!-- Markdown link & img dfn's -->
[BUG: 1728134]: https://bugs.launchpad.net/netplan/+bug/1728134
