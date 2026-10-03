# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Module: Docker Container Build Tools
# Description: Build workflows for BoardPort Qualcomm EDL container image.
# ----------------------------------------------------------------
# Repository: https://github.com/boardport/edl-container
# Author: BoardPort Community <boardport@proton.me>
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Context variables
PROJECT_MAKE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJECT_ROOT_DIR ?= $(abspath $(PROJECT_MAKE_DIR)/..)

# Docker variables
DOCKER_DIR       ?= $(PROJECT_ROOT_DIR)/docker
DOCKER_IMAGE     ?= ghcr.io/boardport/edl

# Helper macro to check if a CLI tool exists in system PATH
define check_tool_installed
	@command -v $(1) > /dev/null 2>&1 || { \
		echo "[ERROR] Make: Utility '$(1)' is not installed. Please install it first."; \
		exit 1; \
	}
endef

# ------------------------------------------------------------------------------
# Pre-execution Checks
# ------------------------------------------------------------------------------

docker-check-bin::
	$(call check_tool_installed,docker)

# ------------------------------------------------------------------------------
# Image Build Commands
# ------------------------------------------------------------------------------

.PHONY: \
	docker-build-debian \
	docker-build

docker-build-debian::
	docker build -t "$(DOCKER_IMAGE)" -f "$(DOCKER_DIR)/Dockerfile.debian" "$(PROJECT_ROOT_DIR)"

docker-build:: ## Build or rebuild the EDL container image locally
docker-build:: docker-check-bin docker-build-debian
