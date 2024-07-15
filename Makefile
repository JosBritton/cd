.SILENT:
.DEFAULT_GOAL := build

CHARTS := $(shell find apps/ -regex ".*/upstream/Chart.ya?ml")

%/upstream/values.yml:
	@:

%/upstream/values.yaml:
	@:

%/upstream/Chart.yml: %/upstream/values.yaml %/upstream/values.yml
	@:

%/upstream/Chart.yaml: %/upstream/values.yaml %/upstream/values.yml
	@:

%/resources/upstream.yaml: %/upstream/Chart.yaml %/upstream/Chart.yml
	source "$*/BUILDARGS" && \
	helm dependency update "$*/upstream" && \
	helm template \
	    --include-crds \
	    --namespace "$$NAMESPACE" \
	    "$$CHART" \
	    "$*/upstream" > "$@"

RENDERS := $(foreach c,$(CHARTS),$(shell dirname $(shell dirname $(c)))/resources/upstream.yaml)

.PHONY: all
all: build

.PHONY: build
build: $(RENDERS)

.PHONY: renderclean
renderclean:
	find apps/ -regex ".*/resources/upstream.ya?ml" -delete

.PHONY: clean
clean:
	(. .venv/bin/activate && pre-commit uninstall) || true
	rm -rf .venv/

.PHONY: lint
lint: .venv/lock | .gitignore
	. ./.venv/bin/activate && \
	python3 -m yamllint .

.PHONY: validate-ci
validate-ci:
# kustomize validation
	command -v kustomize &> /dev/null || \
		(echo "Error: Kustomize not installed"; exit 1)

	kustomize build bootstrap/argo-cd

	set -e; \
	for k in $$(find apps/ -name kustomization.yaml); do \
	kustomize build "$$(dirname $$k)"; done

# helm validation
	command -v helm &> /dev/null || \
		(echo "Error: Helm not installed"; exit 1)

	for c in $(CHARTS); do \
		set -- $$(dirname $$c)/charts/*.tgz; \
		[ -f "$$1" ] || helm dependency update "$$(dirname $$c)"; done

	set -e; \
	for c in $(CHARTS); do \
	. "$$(dirname $$(dirname $$c))/BUILDARGS" && \
	helm template \
		--include-crds \
		--namespace $$NAMESPACE \
		$$CHART \
		$$(dirname $$c); done

.PHONY: validate
validate: validate-ci
# kubeconform validation
	command -v kubeconform &> /dev/null || (echo "Error: Kubeconform not installed"; exit 1)

	kubeconform \
		-skip Kustomization,CustomResourceDefinition \
		-ignore-filename-pattern "apps/.*/upstream/.*\.ya?ml" \
		-ignore-filename-pattern "apps/.*/overlays/.*\.ya?ml" \
		-ignore-filename-pattern "/.*\.json" \
		-schema-location default \
		-schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
		-summary \
		-strict \
		-- apps/

.PHONY: install
install: .git/hooks/pre-commit .git/hooks/pre-push | .gitignore

.PHONY: precommit
precommit: lint

.PHONY: prepush
prepush: lint validate

.venv/lock: requirements.txt
	python3 -m venv .venv/

	. .venv/bin/activate && \
	python3 -m pip install -U -r requirements.txt

	touch .venv/lock

.git/hooks/pre-commit: .pre-commit-config.yaml .venv/lock
	. .venv/bin/activate && \
	pre-commit install --hook-type pre-commit && \
	touch .git/hooks/pre-commit

.git/hooks/pre-push: .pre-commit-config.yaml .venv/lock
	. .venv/bin/activate && \
	pre-commit install --hook-type pre-push && \
	touch .git/hooks/pre-push

.gitignore:
	touch .gitignore
