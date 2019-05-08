# Part 8 -- OpenStack Prep
###### Provision OpenStack Deployment Requirements

Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]

![CCIO Hypervisor - OpenStack Prep](https://github.com/KathrynMorgan/mini-stack/blob/master/8_OpenStack_Deploy/web/drawio/OpenStack-Prep.svg)

-------
#### 01. Virt-Install new vm's (on host)
NOTE: sane defaults set in script hardware profile section, adjust if required
```
wget -O /tmp/virt-inst-stack-nodes.sh https://git.io/fjLpT
source /tmp/virt-inst-stack.sh
```

#### 02. Discover new KVM VIrtual Machines via PODS Refresh  (on host)
```
lxc exec maasctl -- /bin/bash -c "wget -O- https://git.io/fjLpv 2>/dev/null | bash"
```

#### 03. Tag new mini-stack nodes (on host)
```
lxc exec maasctl -- /bin/bash -c "wget -O- https://git.io/fjLpJ 2>/dev/null | bash"
```

#### 04. Create Juju Model
```sh
juju add-model mini-stack
```
#### 05. Add Juju Machines
```sh
for n in 01 02 03; do juju add-machine --constraints tags=mini-stack; done
for n in 01 02 03; do for c in 0 1 2 3; do juju add-machine lxd:${c} --constraints spaces=lan; done; done
```
#### 06. Deploy OpenStack from Juju Bundle YAML File
```sh
wget -O /tmp/mini-stack-openstack-bundle.yaml
juju deploy /tmp/mini-stack-openstack-bundle.yaml
```
#### 07. Monitor Deploy
```sh
watch -c juju status --color
juju debug-log
```

- [Part 9 Kubernetes Deploy]
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
[Part 9 Kubernetes Deploy]: ../9_Kubernetes_Deploy
