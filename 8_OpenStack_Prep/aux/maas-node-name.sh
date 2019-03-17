#!/bin/bash
for machineb64 in $(maas admin machines read | jq -rc '.[] | @base64'); do
    machine_json=$(echo $machineb64 | base64 --decode)
    machine_id=$(echo $machine_json | jq -r '.system_id')
    machine_serial=$(echo $machine_json | jq -r '.hardware_info.system_serial')
    echo rename $machine_id to $machine_serial
    maas admin machine update $machine_id hostname=$machine_serial
done
