#!/usr/bin/env bash

set -e

cd ${DCOS_HOME}

[ -z "$HELM_INSTALLED" ] && echo "Helm and tiller must be installed ..." && ./helm.sh

CHE_KUBERNETES_YAML_URL=https://raw.githubusercontent.com/eclipse/che/master/deploy/kubernetes/kubectl/che-kubernetes.yaml
curl -fsSL ${CHE_KUBERNETES_YAML_URL} | sed "s/192.168.99.100/https://$(make get-master-lb-ip)\/service\/kubernetes-proxy/" > che-kubernetes.yaml

kubectl create namespace che
kubectl --namespace=che apply -f che-kubernetes.yaml

# Advanced installation with multiusers and ingress service at: https://www.eclipse.org/che/docs/kubernetes-multi-user.html