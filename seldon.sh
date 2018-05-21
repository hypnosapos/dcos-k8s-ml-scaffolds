#!/usr/bin/env bash

set -e

[ -z "$GITHUB_TOKEN" ] && echo "Env variable GITHUB_TOKEN not defined" && exit 1

TAG_NAME=$(curl -H "Authorization: token ${GITHUB_TOKEN}" -s https://api.github.com/repos/kubernetes/helm/releases/latest | jq -r ".tag_name")
curl -L -H "Authorization: token ${GITHUB_TOKEN}" https://storage.googleapis.com/kubernetes-helm/helm-${TAG_NAME}-linux-amd64.tar.gz -o helm.tar.gz
tar -xzvf helm.tar.gz --wildcards --no-anchored 'helm' --strip-components=1 && mv ./helm /usr/local/bin/

kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller


helm init --service-account tiller

helm install seldon-core-crd --name seldon-core-crd \
     --repo https://storage.googleapis.com/seldon-charts \
     --set usage_metrics.enabled=true \
     --set rbac.enabled=false


kubectl create namespace seldon

helm install seldon-core --name seldon-core \
     --repo https://storage.googleapis.com/seldon-charts \
     --set rbac.enabled=false \
     --namespace seldon

helm install seldon-core-analytics --name seldon-core-analytics \
     --repo https://storage.googleapis.com/seldon-charts \
     --set grafana_prom_admin_password=password \
     --set persistence.enabled=false \
     --set rbac.enabled=false \
     --namespace seldon

export SELDON_INSTALLED=true

# kubectl port-forward --namespace=seldon $(kubectl get pods --namespace=seldon --selector="app=seldon-apiserver-container-app" --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}") 8080:8080 &
# kubectl port-forward --namespace=seldon $(kubectl get pods --namespace=seldon --selector="app=grafana-prom-server" --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}") 3000:3000 &
