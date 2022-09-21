#!/usr/bin/env bash

set -e

kubectl config view --raw -o json | jq -r '.clusters[] | select(.name == "k3d-lxc-localdev") | .cluster["certificate-authority-data"]' | base64 --decode