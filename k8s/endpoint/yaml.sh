#!/usr/bin/env bash

IP=$(kubectl get cm coredns --namespace kube-system -o jsonpath='{.data.NodeHosts}' | grep host.k3d.internal | awk '{print $1}')

ytt \
	-f k8s/endpoint \
	--data-value "dockerHostAddress=${IP}" \
	--data-value "virtualInstanceId=${1}"