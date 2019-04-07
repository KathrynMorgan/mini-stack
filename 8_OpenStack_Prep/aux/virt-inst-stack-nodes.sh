#!/bin/bash
#set -x

# Set VM creation count
vm_COUNT="03"
name_BASE="mini-stack"

# Hardware Profile
#vm_RAM=2048
vm_RAM=4086
vm_CPU=2
storage_POOL="/var/lib/libvirt/images"

# If set to 'true' will disable sleep interval between spawn loops
run_FAST="true"

spawn_build () {
virt-install \
    --pxe \
    --hvm \
    --noreboot \
    --noautoconsole \
    --graphics none \
    --os-type=Linux \
    --vcpus=${vm_CPU} \
    --memory=${vm_RAM} \
    --name=${name_FULL} \
    --cpu host-passthrough \
    --os-variant=ubuntu18.04 \
    --boot 'network,hd,useserial=on' \
    --description 'juju maas cloud mini-stack node' \
    --network network=lan,model=virtio,mac=${eth0_HWADDRESS} \
    --network network=lan,model=virtio,mac=${eth1_HWADDRESS} \
    --network network=lan,model=virtio,mac=${eth2_HWADDRESS} \
    --network network=lan,model=virtio,mac=${eth3_HWADDRESS} \
    --disk path=${storage_POOL}/${name_FULL}_vda.qcow2,format=raw,bus=virtio,cache=unsafe,size=32 \
    --disk path=${storage_POOL}/${name_FULL}_vdb.qcow2,format=raw,bus=virtio,cache=unsafe,size=32 \
    --disk path=${storage_POOL}/${name_FULL}_vdc.qcow2,format=raw,bus=virtio,cache=unsafe,size=32

# Prevent the VM from pxe booting to autodiscovery in maas
sleep 1 && virsh destroy ${name_FULL}

}

spawn_prep () {
eth0_HWADDRESS=$(echo "${name_FULL} lan eth0" | md5sum \
    | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
eth1_HWADDRESS=$(echo "${name_FULL} lan eth1" | md5sum \
    | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
eth2_HWADDRESS=$(echo "${name_FULL} lan eth2" | md5sum \
    | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')
}

run_spawn () {
for count in $(seq -w 01 ${vm_COUNT}); do
       
       # Set VM Name & Declare Build
       name_FULL="${name_BASE}-${count}"
       echo "Building ${name_FULL}"

       # Set variables for spawn build
       spawn_prep
       spawn_build

       # If run fast disabled will pause for anti flood safety interval
       [[ $run_FAST == "true" ]] || sleep 30

done
}

run_spawn

#################################################################################
# TESTING
# qemu-img create -f qcow2 -o preallocation=metadata,compat=1.1 /tmp/image.qcow2 36G
# chown qemu /tmp/image.qcow2
#   --network network=lan,model=virtio,mac=${eth1_HWADDRESS} \
#   --disk path=${storage_POOL}/${name_FULL}_vdb.qcow2,format=raw,bus=virtio,cache=unsafe,size=32
