#!/bin/sh
[ -z "$XDG_CACHE_HOME" ] && cache_dir="$HOME/.cache" || cache_dir="$XDG_CACHE_HOME"
mkdir -p "$cache_dir/kubeconform"

kubeconform \
  -n "$(nproc)" \
  --cache "$cache_dir/kubeconform" \
  --skip CustomResourceDefinition \
  --ignore-filename-pattern "apps/.*/upstream/.*\.ya?ml" \
  --ignore-filename-pattern "apps/.*/overlays/.*\.ya?ml" \
  --ignore-filename-pattern "apps/.*/files/.*\.ya?ml" \
  --ignore-filename-pattern "/.*\.json" \
  --schema-location default \
  --schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
  --schema-location "https://json.schemastore.org/{{.ResourceKind}}.json" \
  --summary \
  --strict \
  --verbose \
  -- "$@"
