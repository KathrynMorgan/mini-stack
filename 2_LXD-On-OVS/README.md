# Part 2 -- LXD On Open vSwitch Network
###### Install and Configure LXD on a default Open vSwitch Network Bridge
###### NOTE: This will expose containers on your LAN by default

Prerequisites:
- [Part_0 Host System Prep]
- [Part_1 Single Port Host OVS Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/2_LXD-On-OVS/web/drawio/lxd-on-openvswitch.svg)

## Instructions:
#### 1. Install LXD Packages
````sh
apt install -y lxd squashfuse zfsutils-linux btrfs-tools && sudo modprobe zfs
````

#### 3. Initialize LXD
With example enswers
````sh
sudo lxd init
````
###### Example Interactive Init
````
root@bionic:~# lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: default
Name of the storage backend to use (btrfs, dir, lvm) [default=btrfs]: dir
Would you like to connect to a MAAS server? (yes/no) [default=no]: no
Would you like to create a new local network bridge? (yes/no) [default=yes]: no
Would you like to configure LXD to use an existing bridge or host interface?(yes/no) [default=no]: yes
Name of the existing bridge or host interface: wan
Would you like LXD to be available over the network? (yes/no) [default=no]: yes
Address to bind LXD to (not including port) [default=all]: all
Port to bind LXD to [default=8443]: 8443
Trust password for new clients:
Again:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] yes
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
````
#### 4. Add your user(s) to the 'lxd' group with the following syntax for each user
Replace '$USERNAME' with your user name
````sh
sudo usermod -aG lxd $USERNAME
````
#### 5. Backup the original lxc profile
````
lxc profile copy default original
````
#### PROTIP: Launch Containers & check Configurations
###### Exhibit(A): Add cloud-init user-data to your default profile
###### Download the example, edit, then apply as follows
````
update-alternatives --set editor /usr/bin/vim.basic
lxc profile edit default
````
````
wget https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/2_LXD-On-OVS/aux/example-default-profile.yaml
vim example-default-profile.yaml
lxc profile edit default < example-default-profile.yaml
````
###### Exhibit(B): Add 'lxc' command alias 'ubuntu' to auto login to containers as user 'ubuntu'
````
sed -i 's/aliases: {}/aliases:\n  ubuntu: exec @ARGS@ -- sudo --login --user ubuntu/g' .config/lxc/config.yml
lxc ubuntu ${container_NAME}
````
###### Exhibit(B): Launch Containers
````
lxc launch ubuntu: c01
lxc launch ubuntu:bionic test-bioinic
lxc launch images:centos/7 test-centos
lxc launch images:fedora/28 test-fedora
lxc exec c01 bash
````

#### Exhibit(C): Check LXD Configurations
````sh
lxc list
lxc network list
lxc network show wan
lxc profile list
lxc profile show default
lxc config show c01
````

## Next sections
- [PART_3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
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
