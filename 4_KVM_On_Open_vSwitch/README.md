# Part 4 -- KVM On Open vSwitch
###### Install and Configure Libvirt / KVM / QEMU on a Default Open vSwitch Network
Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/4_KVM_On_Open_vSwitch/web/drawio/kvm-on-open-vswitch.svg)

## Instructions: 
#### 1. Install Packages
````sh
apt install -y qemu qemu-kvm qemu-utils libvirt-bin libvirt0
````
#### 2. Backup & Destroy default NAT Network
````sh
mkdir ~/bak 2>/dev/null ; virsh net-dumpxml default | tee ~/bak/virsh-net-default-bak.xml
virsh net-destroy default && virsh net-undefine default
````
#### 3. Write xml config for 'default' network on 'lan' bridge
````sh
cat <<EOF >/tmp/virsh-net-default-on-lan.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='lan' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
#### 4. Write xml config 'lan' network on 'lan' bridge
````sh
cat <<EOF >/tmp/virsh-net-lan-on-lan.json
<network>
  <name>lan</name>
  <forward mode='bridge'/>
  <bridge name='lan' />
  <virtualport type='openvswitch'/>
</network>
EOF

````
#### 5. Write xml config 'wan' network on 'wan' bridge
````sh
cat <<EOF >/tmp/virsh-net-wan-on-wan.json
<network>
  <name>wan</name>
  <forward mode='bridge'/>
  <bridge name='wan' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
#### 6. Create networks from config files
````sh
for i in virsh-net-default-on-lan.json virsh-net-lan-on-lan.json virsh-net-wan-on-wan.json; do virsh net-define /tmp/$i; done
for i in wan default lan; do virsh net-start $i; virsh net-autostart $i; done
````
#### 7. Verify virsh network:
````sh
sudo virsh net-list --all
````
````sh
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
 lan                  active     yes           yes
 wan                  active     yes           yes
````

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part_6 MAAS POD Configuration on Libvirt Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider


#### ProTip: ENABLE Host 'root' Auth via key pair
````
sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
````
