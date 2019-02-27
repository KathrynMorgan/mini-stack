# Part_7 -- Add LXD & KVM Hypervisor Node

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]

![CCIO_Hypervisor](https://blablabla.bla)

# Instructions:
#### 01. Install Packages
````
apt install -y openvswitch-switch qemu qemu-kvm qemu-utils libvirt-bin libvirt0
````

#### 01. Destroy Default Libvirt Networking
````
mkdir ~/bak && virsh net-dumpxml default | tee ~/bak/virsh-net-default-bak.xml
virsh net-destroy default && virsh net-undefine default
````

#### 02. Write Systemd-Networkd bridge & host Port Configuration
````
export lan_NIC="ens4"
````
````
cat <<EOF > /etc/systemd/network/${lan_NIC}.network                                                    
[Match]
Name=${lan_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````
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

#### 04. Create Bridge & mgmt1 Interface
````
export HWADDRESS=$(echo "$HOSTNAME lan mgmt1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
````
````
ovs-vsctl add-br lan -- add-port lan mgmt1 -- set interface mgmt1 type=internal -- set interface mgmt1 mac="$HWADDRESS"
````

#### 03. Re-Configure Netplan for mgmt1 Interface
````
np_YAML=$(ls /etc/netplan/)
sed -i 's/${lan_NIC}.*/mgmt1/g' /etc/netplan/${np_YAML}
````
````
phys_MAC=$(awk '/macaddress: /{print $2}' /etc/netplan/${np_YAML})
sed -i 's/${phys_MAC}/${HWADDRESS}/g' /etc/netplan/${np_YAML}
````

#### 01. Create OVS Lan Bridge Libvirt Networks
````
cat <<EOF >/tmp/virsh-net-default-on-lan.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='lan' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
````
cat <<EOF >/tmp/virsh-net-lan-on-lan.json
<network>
  <name>lan</name>
  <forward mode='bridge'/>
  <bridge name='lan' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
````
for i in virsh-net-default-on-lan.json virsh-net-lan-on-lan.json ; do virsh net-define /tmp/$i; done
for i in default lan; do virsh net-start $i; virsh net-autostart $i; done
````

#### 05. Add Physical NIC to Bridge && Restart Network stack
````
ovs-vsctl add-port lan ${lan_NIC}
systemctl restart systemd-networkd.service
netplan apply --debug
````

#### 01. Enable ssh as 'root'
````
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
````

#### 01. Add as MAAS POD

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
