.DEFAULT_GOAL := help

# Use force targets instead of listing all the targets we have via .PHONY
# https://www.gnu.org/software/make/manual/html_node/Force-Targets.html#Force-Targets
.FORCE:

# Root directory with Makefile
ROOT_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Fedora toolbox version
FEDORA_VERSION=42

# Help prelude
define PRELUDE

Usage:
  make [target]

endef

##@ Setup

setup/pre-commit: .FORCE  ## Setup pre-commit
	pre-commit install

setup/fedora: .FORCE  ## Setup for Fedora-based systems
	sudo dnf -y install nodejs-npm pre-commit uv which

##@ Docs

docs: .FORCE  ## Build documentation locally
	uv run mkdocs build

docs/serve: .FORCE  ## Run documentation development server
	uv run mkdocs serve

##@ Container

build:  ## Build container image
	podman build --build-arg FEDORA_VERSION=$(FEDORA_VERSION) -t ghcr.io/thrix/nix-toolbox:$(FEDORA_VERSION) .

push:  ## Push container image to ghcr.io
	podman push ghcr.io/thrix/nix-toolbox:$(FEDORA_VERSION)

##@ Cleanup

clean: .FORCE  ## Cleanup
	podman rmi ghcr.io/thrix/nix-toolbox:$(FEDORA_VERSION)

##@ Utility

# See https://www.thapaliya.com/en/writings/well-documented-makefiles/ for details.
reverse = $(if $(1),$(call reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1))

help: .FORCE  ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "$(info $(PRELUDE))"} /^[a-zA-Z_/-]+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(call reverse, $(MAKEFILE_LIST))
