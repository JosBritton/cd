#!/bin/bash

bash -c "$(curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3)"
runuser -u ubuntu renovate
