#!/bin/bash

refresh_pods () {
for pod_ID in ${pods_LIST}; do
    maas admin pod refresh -d ${pod_ID}
done
}

query_pods_list () {
pods_LIST=$(maas admin pods read \
           | jq '.[] | {name:.name, id:.id}' --compact-output \
           | awk -F'[":,{}]' '/id/{print $11}'
           )
}

query_pods_list
refresh_pods
