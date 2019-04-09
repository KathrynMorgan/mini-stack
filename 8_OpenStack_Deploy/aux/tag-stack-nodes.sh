#!/bin/bash

add_LIST=""
tag_LIST="mini-stack compute neutron-gw osd"
maas_PROFILE="admin"

tag_nodes () {
for stack_TAG in ${tag_LIST}; do
	maas ${maas_PROFILE} tag update-nodes ${stack_TAG} ${add_LIST}
done
}

append_nodes () {
for stack_NODE in ${stack_LIST}; do
	add_LIST="${add_LIST} add=${stack_NODE}"
done
}

read_nodes () {
stack_LIST=$(maas admin machines read \
	    | jq '.[] | {hn:.hostname, system_id:.system_id}' --compact-output \
	    | awk -F'[":,]' '/mini-stack-../{print $11}')
}

tags_create () {
for stack_TAG in ${tag_LIST}; do
	maas ${maas_PROFILE} tags create name=${stack_TAG}
done
}

tags_create
read_nodes
append_nodes
tag_nodes
