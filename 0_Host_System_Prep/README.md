# Part 0 -- Host System Preparation

#### 00. Review checklist of prerequisites:
  1. You have a fresh install of Ubuntu 18.04 LTS on a machine with no critical data or services on it
  2. You are familiar with and able to ssh between machines
  3. You have an ssh key pair, and uploaded the public key to your Launchpad (RECOMMENDED,) or Github account
  4. Run all prep commands as root
  5. Recommended: Follow these guides using ssh to copy/paste commands as you read along

#### 01. Install helper packages
```sh
apt-get update && apt-get install -y whois vim lnav openssh-server linux-generic-hwe-18.04
```
#### 02. Create host CCIO Profile Configuration && add to bashrc
```sh
wget -O /tmp/build-mini-stack-profile.sh https://git.io/fjLhZ
source /tmp/build-mini-stack-profile.sh
```
#### 03. Replace limited root bashrc
```sh
cp -f /etc/skel/.bashrc /root/.bashrc && source ~/.bashrc
```
#### 04. Import your ssh pub key
```sh
ssh-import-id ${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}
```
#### 05. Enable root user ssh login
```sh
sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
systemctl restart sshd
```
#### 06. Enable PCI Passthrough && Nested Virtual Machines && Revert NIC Interface Naming
```sh
mkdir /etc/default/grub.d
wget -O /etc/default/grub.d/99-libvirt.cfg https://git.io/fjtnT
update-grub
```
#### 07. Change network device name in /etc/netplan/*.yaml to eth0
```sh
sed -i "s/$(ip r | head -n 1 | awk '{print $5}')/eth0/g" /etc/netplan/*.yaml
```
#### 08. Reboot
-------
## OPTIONAL (DESKTOP OS) 
#### OPTIONAL 01. Switch default editor from nano to vim
```sh
update-alternatives --set editor /usr/bin/vim.basic
```
##### OPTIONAL 02. Disable default GUI startup on Desktop OS
  NOTE: Use command `startx` to manually start full GUI environment at will
```sh
systemctl set-default multi-user.target
```
##### OPTIONAL 03. Disable Lid Switch Power/Suspend features if building on a laptop
```sh
sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
```
-------
## Next sections
- [Part 1 Single Port Host Open vSwitch Network Configuration]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part 0 Host System Prep]: ../0_Host_System_Prep
[Part 1 Single Port Host Open vSwitch Network Configuration]: ../1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: ../2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: ../3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: ../4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: ../5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: ../6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: ../7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: ../8_OpenStack_Deploy
