#!/usr/bin/env bash

set -e

[ ! -f /dcos-kubernetes-quickstart/gcp.json ] && ( echo "Required gcp.json file with credentials" && exit 1 )
[ ! -f /dcos-kubernetes-quickstart/dcos_gcp ] && ( echo "Required dcos_gcp private key" && exit 1 )

eval $(ssh-agent) && ssh-add dcos_gcp

make get-cli && mv dcos kubectl /usr/local/bin/

#sed -i -e "s|github.com/dcos/terraform-dcos|github.com/hypnosapos/terraform-dcos|g" ./Makefile
make gcp launch-dcos setup-cli
