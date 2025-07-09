#!/bin/sh
# ACCEPTS path to `kustomization.yaml`
parallel -j0 "kustomize build "{//}"" ::: "$@"
