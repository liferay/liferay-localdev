#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

# Make sure that extensions can resolve host aliases

declare -a host_aliases=("dxp" "vi")
HOST_ALIASES="['dxp', 'vi']"

# create k3d cluster with local registry
CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

# if [ "$CLUSTER" != "" ];then
# 	echo "'localdev' runtime environment already exists"

# 	kubectl config use-context k3d-localdev
# 	kubectl config set-context --current --namespace=default

# 	exit 0
# fi

if [ "$CLUSTER" == "" ];then
	ytt \
		-f ${REPO}/k8s/k3d \
		--data-value-yaml "hostAliases=$HOST_ALIASES" \
		--data-value-yaml "lfrdevDomain=$LFRDEV_DOMAIN" \
		> /tmp/.cluster_config.yaml

	k3d cluster create \
		--config /tmp/.cluster_config.yaml \
		--registry-create registry.lfr.dev:50505 \
		--wait
else
	k3d cluster start localdev
fi

echo "uid=$UID"
echo "user=$(whoami)"

kubectl config use-context k3d-localdev
kubectl config set-context --current --namespace=default

# poll until default service account is created

SA="0"

echo "SERVICEACOUNT_STATUS: waiting..."
until [ "${SA}" == "1" ]; do
	SA=$(kubectl get sa -o json 2>/dev/null | jq -r '.items | length')
	sleep 1
done
echo -e "SERVICEACOUNT_STATUS: Available."

ytt \
	-f ${REPO}/k8s/k3d/localdev-configmap.yaml \
	-f ${REPO}/k8s/tls/rootCA.pem \
	--data-value-yaml "hostAliases=$HOST_ALIASES" \
	--data-value-yaml "lfrdevDomain=$LFRDEV_DOMAIN" \
	> /tmp/.localdev-configmap.yaml

kubectl apply --force -f /tmp/.localdev-configmap.yaml 2>/dev/null
kubectl apply --force -f ${REPO}/k8s/k3d/token.yaml 2>/dev/null
kubectl apply --force -f ${REPO}/k8s/k3d/rbac.yaml 2>/dev/null

kubectl create secret generic lfrdev-tls-secret \
	--from-file=tls.crt=${REPO}/k8s/tls/${LFRDEV_DOMAIN}.crt \
	--from-file=tls.key=${REPO}/k8s/tls/${LFRDEV_DOMAIN}.key  \
	--namespace default --dry-run=client -oyaml \
	> /tmp/.localdev-lfrdev-tls-secret.yaml

kubectl apply --force -f /tmp/.localdev-lfrdev-tls-secret.yaml 2>/dev/null

# poll until coredns is updated with docker host address

ADDRESS=""

echo "DOCKER_HOST_ADDRESS: waiting..."
until [ "${ADDRESS}" != "" ]; do
	ADDRESS=$(\
			kubectl get cm coredns --namespace kube-system \
			-o jsonpath='{.data.NodeHosts}' 2>/dev/null \
		| grep host.k3d.internal | awk '{print $1}')
	sleep 1
done
echo -e "DOCKER_HOST_ADDRESS: ${ADDRESS}"

# poll until the ingressroute CRD has been installed by traefik controller

CRD=""

echo "INGRESSROUTE_CRD: waiting..."
until [ "$CRD" != "" ]; do
	CRD=$(\
			kubectl get crd ingressroutes.traefik.containo.us \
		--ignore-not-found 2>/dev/null)
	sleep 1
done
echo -e "INGRESSROUTE_CRD: ${CRD}"

# setup the dxp endpoint to route requests to dxp instance running on docker host
for hostAlias in ${host_aliases[@]}
do
	ytt \
		-f ${REPO}/k8s/endpoint \
		--data-value "id=${hostAlias}" \
		--data-value-yaml "dockerHostAddress=${ADDRESS}" \
		--data-value "lfrdevDomain=${LFRDEV_DOMAIN}" \
		--data-value "virtualInstanceId=dxp.${LFRDEV_DOMAIN}" \
		> /tmp/.localdev-endpoint-${hostAlias}.yaml

	kubectl apply --force -f /tmp/.localdev-endpoint-${hostAlias}.yaml 2>/dev/null
done

echo "'localdev' runtime environment created."