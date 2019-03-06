#!/bin/bash
# Add nic to series of libvirt vm's
set -x

iface_NAME="eth1"
net_NAME="lan"

for i in 04 05 06 07 08 09 10 11 12; do
host_NAME="stack-${i}"
iface_MAC=$(echo "${host_NAME} ${net_NAME} ${iface_NAME}" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\:\1\:\2\:\3\:\4\:\5/')
iface_XML="/tmp/${host_NAME}-${net_NAME}.xml"
cat <<EOF > ${iface_XML}
<interface type='network'>
  <mac address='${iface_MAC}'/>
  <source network='lan'/>
  <model type='virtio'/>
</interface>
EOF
virsh attach-device --config --domain stack-${i} --file ${iface_XML}
done
