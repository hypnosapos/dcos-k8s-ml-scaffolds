#!/usr/bin/env bash

set -e

[ -z "KUBEFLOW_INSTALLED" ] && ./kubeflow.sh

cd ${DCOS_HOME}/${APP_NAME}

MODEL_COMPONENT=serveInception
MODEL_NAME=inception
MODEL_PATH="gs://kubeflow-models/inception"
ks generate tf-serving ${MODEL_COMPONENT} --name=${MODEL_NAME}
ks param set ${MODEL_COMPONENT} modelPath ${MODEL_PATH}

ks apply default -c ${MODEL_COMPONENT}

# Adding gcloud credentials in order to get model from GCS
COUNT_DOWN=0
while [[ $COUNT_DOWN -lt 100 ]]; do
  status=$(kubectl get deployments inception -o jsonpath='{.status.readyReplicas}' -n ${NAMESPACE})
  if [[ '1' == $status ]]; then
    kubectl patch deployment inception -p "$(cat ${DCOS_HOME}/inception-patch.yaml)" -n ${NAMESPACE}
    echo -e "\033[32mPatching example with GCP credentials\033[0m"
    break;
  fi
  if [[ $COUNT_DOWN -eq 100 ]]; then
    echo -e "\033[31mInception model is not yet :-(\033[0m"
    exit 1
  fi
  echo "Waiting for inception service [${COUNT_DOWN}/100] ..."
  COUNT_DOWN=`expr $COUNT_DOWN + 1`
  sleep 3
done

# KUBEFLOW_EXAMPLE_POD=$(kubectl get pods --namespace=$NAMESPACE --selector="app=inception" --output=template --template="{{with index .items 0}}{{.metadata.name}}{{end}}")


