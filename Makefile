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

.PHONY: clean
clean: mostlyclean
	find apps/ -regex ".*/resources/upstream.ya?ml" -delete

.PHONY: mostlyclean
mostlyclean:
	rm -rf .venv/

.PHONY: lint
lint: .venv/lock | .gitignore
	. ./.venv/bin/activate && \
	python3 -m yamllint .

.PHONY: validate
validate:
# kustomize validation
	kustomize build bootstrap/argo-cd

	set -e; \
	for k in $$(find apps/ -name kustomization.yaml); do \
	kustomize build "$$(dirname $$k)"; done

# helm validation
	set -e; \
	for c in $$(find apps/ -regex ".*/upstream/Chart.ya?ml" -exec dirname {} \;); do \
	. "$$(dirname $$c)/BUILDARGS" && \
	helm dependency update "$$c" && \
	helm template \
		--include-crds \
		--namespace $$NAMESPACE \
		$$CHART \
		$$c; done

.PHONY: install
install: .git/hooks/pre-commit | .gitignore

.PHONY: precommit
precommit: lint

.PHONY: prepush
prepush: lint

.venv/lock: requirements.txt
	python3 -m venv .venv/

	. .venv/bin/activate && \
	python3 -m pip install -U -r requirements.txt

	touch .venv/lock

.git/hooks/pre-commit: .pre-commit-config.yaml .venv/lock
	. .venv/bin/activate && \
	pre-commit install && \
	touch .git/hooks/pre-commit

.gitignore:
	touch .gitignore
