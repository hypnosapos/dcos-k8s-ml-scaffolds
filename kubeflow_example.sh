#!/usr/bin/env bash

set -e

[ -z "KUBEFLOW_INSTALLED" ] && ./kubeflow.sh

cd ${DCOS_HOME}/${APP_NAME}

MODEL_COMPONENT=serveInception
MODEL_NAME=inception
MODEL_PATH=gs://kubeflow-models/inception
ks generate tf-serving ${MODEL_COMPONENT} --name=${MODEL_NAME}
ks param set ${MODEL_COMPONENT} modelPath ${MODEL_PATH}

ks apply default -c ${MODEL_COMPONENT}

