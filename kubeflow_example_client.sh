#!/usr/bin/env bash

set -e

kubectl run inception-client --image hypnosapos/kflow-inception-client:latest --restart=OnFailure -n $NAMESPACE
kubectl logs -f job/inception-client -n kubeflow