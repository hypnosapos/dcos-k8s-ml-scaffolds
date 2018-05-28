#!/usr/bin/env bash

set -e

cd ${DCOS_HOME}

[ -z "$GITHUB_TOKEN" ] && echo "Env variable GITHUB_TOKEN not defined" && exit 1

curl  -H "Cache-Control: no-cache" -H "Authorization: token ${GITHUB_TOKEN}" https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

helm init --wait --service-account tiller

export HELM_INSTALLED=true