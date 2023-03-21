#!/usr/bin/env bash

set -e

kubectl get secret default-token --context 'k3d-localdev' -o jsonpath='{.data.token}' 2>/dev/null | \
	base64 --decode