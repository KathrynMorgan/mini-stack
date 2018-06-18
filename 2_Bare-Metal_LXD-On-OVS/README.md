# CCIO Hypervisor
# Part 2 -- LXD On Open vSwitch network
Prerequisites:
- [Part1 Single Port Host Network Configuration]

![CCIO_Hypervisor - LXD On
OpenvSwitch](https://github.com/KathrynMorgan/small-stack/blob/master/2_Bare-Metal_LXD-On-OVS/web/drawio/lxd-on-openvswitch.svg)
<a href="https://github.com/KathrynMorgan/small-stack/blob/master/2_Bare-Metal_LXD-On-OVS/web/drawio/lxd-on-openvswitch.svg" target="_blank">lxd-on-openvswitch.svg</a>

#### 1. Install LXD Packages
````sh
sudo apt install -y -t xenial-backports \
	lxd \
	lxd-client \
	lxd-tools \
	lxc-common \
	lxcfs \
	liblxc1 \
	uidmap \
	criu \
	zfsutils-linux \
	squashfuse \
	ebtables
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
````
Would you like to use LXD clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]:
Name of the storage backend to use (btrfs, dir, lvm, zfs) [default=zfs]: zfs
Create a new ZFS pool? (yes/no) [default=yes]: yes
Would you like to use an existing block device? (yes/no) [default=no]: no
Size in GB of the new loop device (1GB minimum) [default=15GB]: 15
Would you like to connect to a MAAS server? (yes/no) [default=no]: no
Would you like to create a new network bridge? (yes/no) [default=yes]: no
Would you like to configure LXD to use an existing bridge or host interface? (yes/no) [default=no]: yes
Name of the existing bridge or host interface: physical-net
Is this interface connected to your MAAS server? (yes/no) [default=yes]: no
Would you like LXD to be available over the network? (yes/no) [default=no]: yes
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] yes
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: no
````
#### 4. Add your user to the 'lxd' group
Replace '$USERNAME' with your user name
````sh
sudo usermod -aG lxd $USERNAME
````
#### 4. Launch an Ubuntu lxd container:
````
lxc launch ubuntu: test
lxc list
````

#### 5. Launch alternate images via example:
````
lxc launch ubuntu:bionic test-bioinic
lxc launch images:centos/7 test-centos
lxc launch images:fedora/28 test-fedora
````

#### 6. See your LXD Configurations
````sh
lxc list
lxc network list
lxc network show physical-net
````

<!-- Markdown link & img dfn's -->
[Part1 Single Port Host Network Configuration]: https://github.com/KathrynMorgan/small-stack/blob/master/1_Bare-Metal_Single-Port-OVS-Hypervisor/
