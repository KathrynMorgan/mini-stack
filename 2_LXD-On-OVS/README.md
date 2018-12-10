# Part 2 -- LXD On Open vSwitch Network
###### Install and Configure LXD on a default Open vSwitch Network Bridge
###### NOTE: This will expose containers on your LAN by default

Prerequisites:
- [Part_1 Single Port Host OVS Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](https://github.com/KathrynMorgan/mini-stack/blob/master/2_LXD-On-OVS/web/drawio/lxd-on-openvswitch.svg)

## Instructions:
#### 1. Install LXD Packages
````sh
apt install -y lxd criu squashfuse zfsutils-linux btrfs-tools
````

#### 2. If using ZFS Storage Backend, load ZFS module
````sh
sudo modprobe zfs
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
#### 4. Launch an Ubuntu lxd container:
````
lxc launch ubuntu: c01
lxc list
````

#### Example(A): Launch alternate images:
````
lxc launch ubuntu:bionic test-bioinic
lxc launch images:centos/7 test-centos
lxc launch images:fedora/28 test-fedora
````

#### Example(B): See your LXD Configurations
````sh
lxc list
lxc network list
lxc network show wan
lxc profile list
lxc profile show default
lxc config show c01
````

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
