# Part_7 -- Build MAAS Cloud Controller
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
`maas-region apikey --username=$MAASUSERNAME >>~/cloudctl-maas-api.key`

#### Create Juju Controler [ juju-cli client ]
1. Launch & Exec into 'cloudctl' controller <br/>
`lxc profile create cloudctl` <br/>
`lxc profile edit cloudctl < profile-cloudctl.yaml` <br/>
`lxc launch ubuntu:bionic cloudctl -p cloudctl` <br/>
`lxc exec cloudctl bash`
6. Install juju client <br/>
`snap install juju --classic`
7. Create juju config folder <br/>
`mkdir ~/.juju`
9. Add the cloud to your juju <br/>
`juju add-cloud maasctl ~/.juju/maasctl.yaml`
11. Add Credentials for your new maasctl cloud <br/>
`juju add-credential maasctl`
* answer credential name request
[ Example: maasctl-admin ]
* copy paste the MAAS API Key
12. Double Check your new juju cloud provider <br/>
`juju show-cloud maasctl`

#### Bootstrap a Juju controller
PROTIP: Remember, if you followed previous guides, you can go to the
libvirt host and use 'virsh list' and 'virsh console' to monitor
the vm's console during bootstrap <br/>

`juju bootstrap maasctl --bootstrap-series=xenial maasctl maasctl-ctl01 --config bootstrap-timeout=1800 --constraints "cores=4 mem=4G"`

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
[Part_1 Single Port Host OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part_2 LXD On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/2_LXD-On-OVS
[Part_3 LXD Gateway OVS Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/3_LXD_Network_Gateway
[Part_4 KVM On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/4_KVM_On_Open_vSwitch
[Part_5 MAAS Controller On Open vSwitch Network]: https://github.com/KathrynMorgan/mini-stack/tree/master/5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part_6 MAAS POD Configuration on Libvirt Provider]: https://github.com/KathrynMorgan/mini-stack/tree/master/6_MAAS-Connect_POD_KVM-Provider
