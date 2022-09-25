#!/usr/bin/env bash

set -e

# Make sure that extensions can resolve host aliases

declare -a host_aliases=("dxp" "vi")
HOST_ALIASES="['dxp', 'vi']"

ytt -f /repo/k8s/k3d --data-value-yaml "hostAliases=$HOST_ALIASES" > .cluster_config.yaml

# create k3d cluster with local registry

k3d cluster create \
  --config .cluster_config.yaml \
  --registry-create registry.localdev.me:5000 \
  --wait

kubectl config use-context k3d-localdev
kubectl config set-context --current --namespace=default

# poll until default service account is created

SA="0"

echo -n "SERVICEACOUNT_STATUS: waiting..."
until [ "${SA}" == "1" ]; do
	SA=$(kubectl get sa -o json | jq -r '.items | length')
done
echo -e "\rSERVICEACOUNT_STATUS: Available."

kubectl create -f /repo/k8s/k3d/token.yaml
kubectl create -f /repo/k8s/k3d/rbac.yaml

kubectl create secret generic localdev-tls-secret \
  --from-file=tls.crt=/repo/k8s/tls/localdev.me.crt \
  --from-file=tls.key=/repo/k8s/tls/localdev.me.key  \
  --namespace default

# poll until coredns is updated with docker host address

ADDRESS=""

echo -n "DOCKER_HOST_ADDRESS: waiting..."
until [ "${ADDRESS}" != "" ]; do
	ADDRESS=$(kubectl get cm coredns --namespace kube-system -o jsonpath='{.data.NodeHosts}' | grep host.k3d.internal | awk '{print $1}')
done
echo -e "\rDOCKER_HOST_ADDRESS: ${ADDRESS}"

# poll until the ingressroute CRD has been installed by traefik controller

CRD=""

echo -n "INGRESSROUTE_CRD: waiting..."
until [ "$CRD" != "" ]; do
  CRD=$(kubectl get crd ingressroutes.traefik.containo.us --ignore-not-found)
done
echo -e "\rINGRESSROUTE_CRD: ${CRD}"

# setup the dxp endpoint to route requests to dxp instance running on docker host
for hostAlias in ${host_aliases[@]}
do
  ytt \
    -f /repo/k8s/endpoint \
    --data-value "id=${hostAlias}" \
    --data-value-yaml "dockerHostAddress=${ADDRESS}" \
    --data-value "virtualInstanceId=dxp.localdev.me" | kubectl apply -f-
done

# build DXP image
/repo/scripts/dxp-build.sh

echo "localdev has been provisioned and is ready for development.  Run localdev-up.sh from your client-extensions workspace."