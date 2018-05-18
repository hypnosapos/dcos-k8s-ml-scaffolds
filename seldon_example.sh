#!/usr/bin/env bash

set -e

[ -z "SELDON_INSTALLED" ] && ./seldon.sh

helm install cartpole-rl-remote --name cartpole \
     --repo https://storage.googleapis.com/hypnosapos-charts \
     --set model_type=model
