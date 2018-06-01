###########################################################################################
## How to install LXD with a default OVS bridge network
## NOTE: This assumes we're attaching to OVS Bridge 'physical-net'

###########################################################################################
## Install LXD Packages
	apt install -y -t xenial-backports \
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

###########################################################################################
## If using ZFS Storage Backend, load ZFS module
modprobe zfs

###########################################################################################
## Initialize LXD w/ example question/answer options
lxd init
*** 
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
***
###########################################################################################
## Launch an lxd container to test
lxc launch ubuntu: test
lxc list

###########################################################################################
## Launch alternate images via example
lxc launch images:centos/7 centos01