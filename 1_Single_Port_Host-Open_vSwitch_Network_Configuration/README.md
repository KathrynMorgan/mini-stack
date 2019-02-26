# Part 1 -- Single Port Host Open vSwitch Network Configuration
#### Provision a host virtual entry network viable for cloud scale emulation and testing.
 WARNING: Exercise caution when performing this proceedure remotely as this may cause loss of connectivity.    
 NOTE:  Netplan does not support raising interfaces without ip addresses. Until the issue is resolved we will use systemd-networkd.
>
> Overview of Steps:
> - Install required packages
> - Enable Open vSwitch Service & Confirm running status
> - Create base OVS Bridge for interfacing with local physical network
> - Create a virtual host ethernet port on the 'wan' bridge
> - Impliment 'systemd-networkd' workaround RE: [BUG: 1728134]

![CCIO_Hypervisor-mini_Stack_Diagram](https://github.com/KathrynMorgan/mini-stack/blob/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration/web/drawio/single-port-ovs-host.svg)

## Instructions:
#### 1. Update system
```
apt update && apt upgrade -y
```

#### 2. Install Packages
```
apt install -y openvswitch-switch
```

#### 3. Create OVS  'wan'  Bridge
```
ovs-vsctl add-br wan
```

#### 4. Write systemd-networkd config to raise interface without IP address [EXAMPLE: '${phys_NIC}']
```sh
Set your physical nic
ip a
export phys_NIC="enp9s0"
````
````
cat <<EOF > /etc/systemd/network/${phys_NIC}.network                                                    
[Match]
Name=${phys_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````

#### 5. Write systemd-networkd config to raise 'wan' bridge

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

#### 6. Attach bridge to LAN

````
ovs-vsctl add-port wan ${phys_NIC}
systemctl restart systemd-networkd.service
````

#### 7. Generate MAC address for virtual interface 'mgmt0'
```
export HWADDRESS=$(echo "$HOSTNAME lan mgmt0" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
```

#### 8. Create host virtual interface on bridge
```
ovs-vsctl add-port wan mgmt0 \
  -- set interface mgmt0 type=internal \
  -- set interface mgmt0 mac="$HWADDRESS"
ovs-vsctl show
```

#### 9. Add mgmt0 netplan config
````
cat <<EOF > /etc/netplan/80-mgmt0.yaml
# Configure mgmt0 on 'wan' bridge
# For more configuration examples, see: https://netplan.io/examples
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt0:
      dhcp4: true
EOF
````

#### 10. Apply configuration
````
netplan apply --debug
````

#### Useful Commands
````
ip r
ip a s
ovs-vsctl show
systemd-resolve --status
````
<!-- Markdown link & img dfn's -->
[BUG: 1728134]: https://bugs.launchpad.net/netplan/+bug/1728134
