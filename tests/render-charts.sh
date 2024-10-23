#!/bin/sh
# ACCEPTS path to `Chart.yaml|Chart.yml`
parallel -j0 "helm dependency update {//} && helm template --include-crds --namespace testns -- testchart {//}" ::: "$@"
