# Part_7 -- Juju MAAS Cloud
###### Create a Juju Cloud on MAAS & Bootstrap the Juju Controller

Prerequisites:
- [Part_1 Single Port Host OVS Network]
- [Part_2 LXD On Open vSwitch Network]
- [Part_3 LXD Gateway OVS Network]
- [Part_4 KVM On Open vSwitch Network]
- [Part_5 MAAS Controller On Open vSwitch Network]
- [Part_6 MAAS POD Configuration on Libvirt Provider]

# Instructions:
#### Generate a MAAS API Key using your maas login username
[ On MAAS-controller ]
1. Generate a MAAS API key for autnentication <br/>
`maas-region apikey --username=$MAASUSERNAME`
* Save API Key for registering juju later

#### Create Juju Controler [ juju-cli client ]
1. Configure base 'jujuctl' controller <br/>
`lxc launch ubuntu:bionic jujuctl` <br/>
`lxc network attach maas-net jujuctl eth1 eth1`
2. Obtain root shell in the container <br/>
`lxc exec jujuctl bash`
3. Add netplan config for netplan <br/>
````sh
cat <<EOF >> /etc/netplan/50-cloud-init.yaml
    eth1:
        dhcp4: true
EOF
````
4. Raise Interface <br/>
`ip link set eth1 up`
5. Update Packages <br/>
`sudo apt update && sudo apt upgrade -y` <br/>
`sudo apt install squashfuse snapd -y` <br/>
6. Install juju client <br/>
`snap install juju --classic`
7. Create juju config folder <br/>
`mkdir ~/.juju`

#### Configure MAAS as a JUJU Cloud Provider
1. Create maas cloud config yaml <br/>
Example MAAS Server IP: 172.1.0.1 <br/>
````sh
cat <<EOF >>~/.juju/maaslab.yaml
clouds:
    maaslab:
        type: maas
        auth-types: [oauth1]
        endpoint: http://172.1.0.1:5240/MAAS
EOF
````
9. Add the cloud to your juju <br/>
`juju add-cloud maaslab ~/.juju/maaslab.yaml`
10. confirm maaslab added successfully <br/>
`juju clouds | grep maaslab`

11. Add Credentials for your new maaslab cloud <br/>
`juju add-credential maaslab`
* answer credential name request
[ Example: maaslab-admin ]
* copy paste the MAAS API Key
12. Double Check your new juju cloud provider <br/>
`juju show-cloud maaslab`

#### Bootstrap a Juju controller
PROTIP: Remember, if you followed previous guides, you can go to the
libvirt host and use 'virsh list' and 'virsh console' to monitor
the vm's console during bootstrap <br/>

`juju bootstrap maaslab --bootstrap-series=xenial maaslab maaslab-ctl01 --config bootstrap-timeout=1800 --constraints "cores=4 mem=4G"`

#### Add new machines on your cloud
1. Add 2 Libvirt guests configured with 2 cores and 2GB RAM <br/>
`juju add-machine -n 2 --constraints "cores=2 mem=2G"`
2. Add 2 new lxd containers <br/>
`juju add-machine lxd -n 2`

#### Find juju WebGUI
`juju gui`

## Launch your first juju charm
`juju deploy -n 1 haproxy`

<!-- Markdown link & img dfn's -->
[Part_1 Single Port Host OVS Network]: 
[Part_2 LXD On Open vSwitch Network]: 
[Part_3 LXD Gateway OVS Network]: 
[Part_4 KVM On Open vSwitch Network]: 
[Part_5 MAAS Controller On Open vSwitch Network]: 
[Part_6 MAAS POD Configuration on Libvirt Provider]: 
