#!/bin/bash
#set -x

pod_ID="1"

spawn_virt () {
composed_NEW=$(maas admin pod compose $pod_ID \
	cores=2 \
	memory=2048 \
	architecture="amd64/generic" \
	interfaces=eth0:space=lan,eth1:space=lan,eth2:space=lan,eth3:space=lan \
	storage="root:32(default),osd:32(default)" | awk -F'[":/]' '/resource_uri/ {print $10}')

composed_ALL="${composed_ALL} ${composed_NEW}"
echo "Composed new system(s): ${composed_ALL}"
}

spawn_virt

#################################################################################
# REFRENCE: 
# 
# maas admin tags create name=magic
# maas admin tag update-nodes $TAG_NAME add=$SYSTEM_ID_1 add=$SYSTEM_ID_2 remove=$SYSTEM_ID_3
# for i in ks3gts kctrm4 8sgwsn; do maas admin tag update-nodes osd add=$i; done
