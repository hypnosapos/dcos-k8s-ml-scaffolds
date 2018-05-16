#!/usr/bin/env bash

set -e

curl -L -o ks.tar.gz $(curl -s https://api.github.com/repos/ksonnet/ksonnet/releases/latest | jq -r ".assets[] | select(.name | test(\"linux_amd64\")) | .browser_download_url")
tar -zxvf ks.tar.gz --strip-components=1 && mv ./ks /usr/local/bin/

dcos kubernetes kubeconfig

# Default values
NAMESPACE=${NAMESPACE:-"kubeflow"}
APP_NAME=${APP_NAME:-"dcos-kubeflow"}
VERSION=${VERSION:-"v0.1.2"}

if [ -z "$GITHUB_TOKEN" ]
then
    echo "Env variable GITHUB_TOKEN not defined" && exit 1
fi

kubectl create namespace ${NAMESPACE}

# Initialize a ksonnet app. Set the namespace for it's default environment.
APP_NAME=dcos-kubeflow
ks init ${APP_NAME}
cd ${APP_NAME}
ks env set default --namespace ${NAMESPACE}

# Install Kubeflow components
ks registry add kubeflow github.com/kubeflow/kubeflow/tree/${VERSION}/kubeflow

ks pkg install kubeflow/core@${VERSION}
ks pkg install kubeflow/tf-serving@${VERSION}
ks pkg install kubeflow/tf-job@${VERSION}

# Create templates for core components
ks generate kubeflow-core kubeflow-core

# Enable collection of anonymous usage metrics
# Skip this step if you don't want to enable collection.
ks param set kubeflow-core reportUsage false
# Uncomment this line if report usage is activated
# ks param set kubeflow-core usageId $(uuidgen)

# Deploy Kubeflow
ks apply default -c kubeflow-core