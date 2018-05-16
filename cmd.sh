#!/usr/bin/env bash

set -e

[ ! -f /dcos-kubernetes/quickstart/gcp.json ] || $(echo "Required gcp.json file with credentials" && exit 1)
[ ! -f /dcos-kubernetes/quickstart/dcos_gcp ] || $(echo "Required dcos_gcp private key" && exit 1)

eval $(ssh-agent) && ssh-add dcos_gcp

make get-cli && mv dcos kubectl /usr/local/bin/

make gcp deploy


COUNT_DOWN=0
until [[ $COUNT_DOWN -lt 100 ]]; do
  k8s_status=$(dcos service --completed | grep kubernetes | awk '{print $2}')
  if [[ 'True' == $k8s_status ]]; then
    echo "kubernetes service is ready ;-)"
    break;
  fi
  if [[ $COUNT_DOWN -eq 100 ]]; then
    echo "kubernetes service is not OK yet, :-("
    exit 1
  fi
  echo "Waiting for kubernetes service ... [Attempt ${COUNT_DOWN}/100]"
  COUNT_DOWN=`expr $COUNT_DOWN + 1`
  sleep 3
done

echo "Installing kubeflow ..."
./kubeflow.sh