#!/bin/sh
# ACCEPTS path to `Chart.yaml|Chart.yml`
parallel -j0 "[ -L {//}/Chart.lock ] && exit 1; helm dependency update {//} && helm template --include-crds --namespace testns -- testchart {//}" ::: "$@"
