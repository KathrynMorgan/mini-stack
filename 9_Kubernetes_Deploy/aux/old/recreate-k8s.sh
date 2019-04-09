. ./proxyset.sh
juju model-defaults model-defaults.yaml
juju destroy-model -y k8s
juju add-model k8s
juju deploy ./canonical-kubernetes-xenial.yaml
juju config kubernetes-worker --file kubernetes-worker-config.yaml
watch juju status
