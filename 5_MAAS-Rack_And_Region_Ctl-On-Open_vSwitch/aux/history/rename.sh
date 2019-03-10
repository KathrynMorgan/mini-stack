#!/bin/bash
# Update Configuration & Comission New virsh-install nodes
#################################################################################
# Run as $PROFILE
maas_profile=<MAAS PROFILE>
echo $maas_profile


#################################################################################
# Find new-uncomissioned nodes
nodes_NEW=$(maas admin machines read | \
	         jq '.[] | select (.status_name=="New") | .system_id' | \
	    awk -F'["]' '{print $2}')


#################################################################################
# Update Node Configuration 
for new_NODE in ${nodes_NEW}; do
	maas $maas_profile machine update $system_id \
           power_type=virsh \
           hostname=$host_NAME \
           power_parameters_power_id=$host_NAME \
           power_parameters_power_address='qemu+ssh://root@precision.maas/system' 
done


#################################################################################
#maas $PROFILE interfaces read $SYSTEM_ID
