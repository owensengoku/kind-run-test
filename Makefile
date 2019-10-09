
# Init some basic variable
CURDIR := $(shell pwd)
SHELL := /bin/bash
VERSION ?= $(shell git describe --tags)
HOST_OS := $(shell uname -s)

# Include *.mk
TOOL_DIR := $(CURDIR)/tools
TOOL_BIN_DIR := $(TOOL_DIR)/bin
TOOL_TEMP_DIR := $(TOOL_DIR)/tmp
DIRS := \
	$(TOOL_DIR) \
	$(TOOL_BIN_DIR) \
	$(TOOL_TEMP_DIR)
export PATH := $(TOOL_BIN_DIR):$(PATH)

REPO ?= github.com/owensengoku/kind-run-test

ifeq ($(HOST_OS), Darwin)
KIND_SUFFIX = darwin-amd64
else
ifeq ($(HOST_OS), Linux)
KIND_SUFFIX = linux-amd64
else
$(error Unsupported Host OS)
endif
endif

KIND_VERSION = 0.2.1
KIND_WITH_OS = kind-$(KIND_SUFFIX)
KIND_URL = https://github.com/kubernetes-sigs/kind/releases/download/$(KIND_VERSION)/$(KIND_WITH_OS)
KIND_BIN := $(TOOL_BIN_DIR)/kind

$(KIND_BIN): $(TOOL_BIN_DIR)
	@echo "download" $(KIND_URL)
	@curl -sL $(KIND_URL) -o $(KIND_BIN)
	@chmod +x $(KIND_BIN)

KINDEST_IMAGE_TAG ?= v1.13.4.with-helm
KINDEST_IMAGE_REPOSITORY ?= kindest-node
KINDEST_IMAGE := $(KINDEST_IMAGE_REPOSITORY):$(KINDEST_IMAGE_TAG)
KINDEST_EXECUTE_PREFIX := docker exec --env GOPATH=/workdir -w /workdir/src/github.com/owensengoku/kind-run-test/ -it kind-control-plane

# Setup local-k8s for integration test

PHONY += local-k8s.setup
local-k8s.setup: $(KIND_BIN)
	sed 's#@WOKRDIR@#$(PWD)#g'  config.yaml.sample  > config.yaml
	$(KIND_BIN) create cluster --config config.yaml --image $(KINDEST_IMAGE)
	$(KINDEST_EXECUTE_PREFIX) sh scripts/helm-ingres-setup.sh

PHONY += local-k8s.config
local-k8s.config: $(KIND_BIN)
	$(KIND_BIN) get kubeconfig-path --name="kind"

PHONY += local-k8s.load-image
local-k8s.load-image:
	$(KIND_BIN) load docker-image nginx:test-deploy

PHONY += local-k8s.helm-install
local-k8s.helm-install:
	$(KINDEST_EXECUTE_PREFIX) helm install charts/nginx -n test-deploy

PHONY += local-k8s.test
local-k8s.test:
	$(KINDEST_EXECUTE_PREFIX) sh scripts/run-test.sh

PHONY += local-k8s.helm-delete
local-k8s.helm-delete:
	$(KINDEST_EXECUTE_PREFIX) helm delete test-deploy --purge

PHONY += local-k8s.teardown
local-k8s.teardown: $(KIND_BIN)
	$(KIND_BIN) delete cluster

.PHONY: $(PHONY)
