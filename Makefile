.DEFAULT_GOAL := build

CHARTS := $(shell find . -mindepth 3 -maxdepth 3 -regex ".*/upstream/Chart.ya?ml")

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
clean:
	find . -mindepth 3 -maxdepth 3 -regex ".*/resources/upstream.ya?ml" -exec rm {} \;