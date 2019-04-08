# Part 0 -- Host System Preparation

###### 00. Review checklist of prerequisites:
  1. You have a fresh install of Ubuntu 18.04 LTS on a machine whith no critical data or services on it
  2. You are familiar with and able to ssh between machines
  3. You have an ssh key pair, and uploaded the public key to your Launchpad and/or Github account
  4. Run all prep commands as root

###### 01. Install helper packages
```
apt-get update && apt-get install -y whois vim lnav openssh-server linux-generic-hwe-18.04
```
###### 02. Create host CCIO Profile Configuration
```
wget -O /tmp/build-mini-stack-profile.sh https://git.io/fjLhZ
source /tmp/build-mini-stack-profile.sh
```
###### 03. Import your ssh pub key
```
ssh-import-id ${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}
```
###### 04. Enable root user ssh login
```
sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
systemctl restart sshd
```
###### 05. Replace limited root bashrc
```
cp -f /etc/skel/.bashrc /root/.bashrc
```
###### 06. Enable PCI Passthrough && Nested Virtual Machines && Revert NIC Interface Naming
```
mkdir /etc/default/grub.d
wget -O /etc/default/grub.d/libvirt.cfg https://git.io/fjtnT
update-grub
```
###### 07. Reboot
-------
###### OPTIONAL 01. Disable default GUI startup on Desktop OS
  NOTE: Use command `startx` to manually start full GUI environment at will
```
systemctl set-default multi-user.target
```
###### OPTIONAL 02. Disable Lid Switch Power/Suspend features if building on a laptop
```
sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
```
-------
## Next sections
- [Part_1 Single Port Host Open vSwitch Network Configuration]
- [Part_2 LXD On Open vSwitch Network]
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part_4 KVM On Open vSwitch]
- [Part_5 MAAS Region And Rack Server on OVS Sandbox]
- [PART_6 MAAS Connect POD on KVM Provider]
- [PART_7 Juju MAAS Cloud]
- [PART_8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part_0 Host System Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/0_Host_System_Prep
[Part_1 Single Port Host Open vSwitch Network Configuration]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Region And Rack Server on OVS Sandbox]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[PART_6 MAAS Connect POD on KVM Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
[PART_7 Juju MAAS Cloud]: https://github.com/KathrynMorgan/mini-stack/tree/master/7_Juju_MAAS_Cloud
[PART_8 OpenStack Prep]: https://github.com/KathrynMorgan/mini-stack/tree/master/8_OpenStack_Prep
