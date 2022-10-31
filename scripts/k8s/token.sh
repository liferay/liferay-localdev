#!/usr/bin/env bash

set -e

kubectl get secret default-token --context 'k3d-localdev' -o jsonpath='{.data.token}' | \
	base64 --decode