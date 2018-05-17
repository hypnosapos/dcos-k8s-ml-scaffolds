#!/usr/bin/env bash

set -e

ks pkg install kubeflow/seldon

ks generate seldon seldon
