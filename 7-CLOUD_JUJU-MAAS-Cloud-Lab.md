###########################################################################################
## How to build a MAAS provider Juju cloud & Deploy a charm
## NOTE: This assumes you have built prerequisite "CCIO Backend"
## TODO: juju bootstrap manual/172.0.0.113 myprecious
juju bootstrap myprecious --to=172.1.0.105 --credential=myprecious-katamo

## On MAAS-controller
## Generate a MAAS API Key using your maas login username
maas-region apikey --username=$MAASUSERNAME
## Save API Key for registering juju later

## Create Juju Control
lxc launch ubuntu:bionic jujuctl
lxc network attach maas-net jujuctl eth1 eth1
lxc exec jujuctl bash
vim /etc/netplan/50-cloud-init.yaml
****
    eth1:
        dhcp4: true
****
ip link set eth1 up
apt update ; apt install squashfuse snapd -y
snap install juju --classic
mkdir ~/.juju

cat <<EOF >>~/.juju/maaslab.yaml
clouds:
    maaslab:
        type: maas
        auth-types: [oauth1]
        endpoint: http://10.10.10.192:5240/MAAS
EOF

juju add-cloud maaslab ~/.juju/maaslab.yaml
juju clouds | grep maaslab

## Add Credentials for your new maaslab cloud
 1. juju add-credential maaslab
 2. answer credential name request
 -- EG: maaslab-admin
 3. copy paste the MAAS API Key
 4. Double Check with: juju show-cloud maaslab
 
 ## Bootstrap a new controller
 ## PROTIP: Remember, if you followed previous guides, you can go to the
 ##         libvirt host and use 'virsh list' and 'virsh console' to monitor
 ##         the vm's console during bootstrap
 
 juju bootstrap maaslab \
   --bootstrap-series=xenial maaslab maaslab-ctl01 \
   --config bootstrap-timeout=1800 \
   --constraints "cores=4 mem=4G"
 
 ## Add 2 new libvirt machines for giggles
 juju add-machine -n 2 --constraints "cores=4 mem=4G"
 
 ## Add 2 new lxd containers 
 juju add-machine lxd -n 2
 
 ## Find juju WebGUI 
 juju gui
 
## Add maas-gw rule to fwd port 17070 to juju controller
## ## from base host
## ## Assume: juju-gui address 172.100.7
## ##   
lxc exec maas-net-gw01 bash
vim /root/lxd-router/iptables-enabled/iptables.fwd
****
#!/bin/bash
# JUJU GUI 17070
# Set Forwarding IP Address
fwd_JUJU_GUI="172.10.0.7"
# Set Forwarding Table
iptables -A PREROUTING -t nat -i $external_IFACE -p tcp --dport 17070 -j DNAT --to $fwd_JUJU_GUI:17070
iptables -A FORWARD -i $external_IFACE -o $internal_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -d $fwd_JUJU_GUI --dport 17070 -j ACCEPT
****
## Test JUJU GUI using your 'maas-net-gw01' LAN or Public IP Address
## ## NOTE! it is not recommended to make this publicly accessible on your WAN address
## ## EG: instead of https://172.10.0.7:17070/gui/u/admin/default using your 'juju controller' ip do
## ##                https://10.10.10.195:17070/gui/u/admin/default where 10.10.10.195 is the lxd 'maas-net-gw01' IP

## Launch your first juju charm
juju deploy -n 1 haproxy