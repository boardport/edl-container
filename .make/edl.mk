# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Module: Qualcomm EDL Container Workflows
# Description: Autonomous Docker CLI commands for Qualcomm 9008 Emergency Download mode.
# ----------------------------------------------------------------
# Repository: https://github.com/boardport/edl-container
# Author: BoardPort Community <boardport@proton.me>
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Context variables
PROJECT_MAKE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJECT_ROOT_DIR ?= $(abspath $(PROJECT_MAKE_DIR)/..)
CTX_UID          := $(shell id -u)
CTX_GID          := $(shell id -g)

# EDL variables
EDL_DUMP_DIR     ?= $(PROJECT_ROOT_DIR)/dumps
EDL_IMAGE        ?= ghcr.io/boardport/edl

# Autonomous Docker CLI runner (no Docker Compose dependency)
EDL_DOCKER_RUN ?= docker run -it --rm \
	--privileged \
	--net=host \
	-v /dev/bus/usb:/dev/bus/usb \
	-v "$(EDL_DUMP_DIR):/opt/edl/dumps" \
	-e EDL_DUMP_UID=$(CTX_UID) \
	$(EDL_IMAGE)

# Helper macro to check if a CLI tool exists in system PATH
define check_tool_installed
	@command -v $(1) > /dev/null 2>&1 || { \
		echo "[ERROR] Make: Utility '$(1)' is not installed. Please install it first."; \
		exit 1; \
	}
endef

# ------------------------------------------------------------------------------
# Pre-execution Checks (Internal)
# ------------------------------------------------------------------------------

docker-check-bin::
	$(call check_tool_installed,docker)

edl-check-dumps::
	@mkdir -p "$(EDL_DUMP_DIR)"

edl-check:: docker-check-bin edl-check-dumps

# ------------------------------------------------------------------------------
# Generic EDL Runner & Interactive Shell
# ------------------------------------------------------------------------------

.PHONY: \
	edl \
	edl-sh

edl:: edl-check ## Run arbitrary EDL command or show built-in help (Usage: make edl [args...])
	@$(EDL_DOCKER_RUN) $(if $(strip $(MAKEARGS)),$(MAKEARGS),--help)

edl-sh:: edl-check ## Open interactive bash shell inside EDL container
	@echo "[INFO] Make: Spawning interactive shell in EDL container..."
	@$(EDL_DOCKER_RUN) bash

# ------------------------------------------------------------------------------
# Device Inspection & Diagnostics
# ------------------------------------------------------------------------------

.PHONY: \
	edl-printgpt \
	edl-storageinfo

edl-printgpt:: edl-check ## Print partition table (GPT) of connected Qualcomm device
	@$(EDL_DOCKER_RUN) printgpt $(MAKEARGS)

edl-storageinfo:: edl-check ## Print storage hardware info (eMMC/UFS/NAND, sectors, blocks)
	@$(EDL_DOCKER_RUN) getstorageinfo $(MAKEARGS)

# ------------------------------------------------------------------------------
# Backup & Read Operations
# ------------------------------------------------------------------------------

.PHONY: \
	edl-rl \
	edl-r \
	edl-rf

edl-rl:: edl-check ## Dump ALL partitions from flash to dumps directory
	@echo "[INFO] Make: Dumping all partitions to $(EDL_DUMP_DIR)..."
	@$(EDL_DOCKER_RUN) rl dumps $(MAKEARGS)

edl-r:: edl-check ## Read specific partition (Usage: make edl-r <partition> [file])
	@if [ -z "$(strip $(MAKEARGS))" ]; then \
		echo "[ERROR] Make: Specify partition name. Example: make edl-r boot [dumps/boot.img]"; \
		exit 1; \
	fi
	@$(EDL_DOCKER_RUN) r $(MAKEARGS)

edl-rf:: edl-check ## Read whole physical flash memory to a raw disk image
	@$(EDL_DOCKER_RUN) rf $(if $(strip $(MAKEARGS)),$(MAKEARGS),dumps/full_flash.bin)

# ------------------------------------------------------------------------------
# Flashing & Erase Operations
# ------------------------------------------------------------------------------

.PHONY: \
	edl-w \
	edl-erase

edl-w:: edl-check ## Write image to a specific partition (Usage: make edl-w <partition> <file>)
	@if [ -z "$(strip $(MAKEARGS))" ]; then \
		echo "[ERROR] Make: Specify partition and file. Example: make edl-w boot dumps/boot.img"; \
		exit 1; \
	fi
	@$(EDL_DOCKER_RUN) w $(MAKEARGS)

edl-erase:: edl-check ## Erase a specific partition (Usage: make edl-erase <partition>)
	@if [ -z "$(strip $(MAKEARGS))" ]; then \
		echo "[ERROR] Make: Specify partition name to erase. Example: make edl-erase userdata"; \
		exit 1; \
	fi
	@$(EDL_DOCKER_RUN) e $(MAKEARGS)

# ------------------------------------------------------------------------------
# Power Management & Device Reset
# ------------------------------------------------------------------------------

.PHONY: \
	edl-reset \
	edl-reset-edl

edl-reset:: edl-check ## Reboot device from EDL mode into normal system
	@echo "[INFO] Make: Rebooting device from EDL..."
	@$(EDL_DOCKER_RUN) reset --resetmode=reset $(MAKEARGS)

edl-reset-edl:: edl-check ## Reboot device back into EDL mode (Warm EDL reset)
	@echo "[INFO] Make: Resetting device back into EDL mode..."
	@$(EDL_DOCKER_RUN) reset --resetmode=edl $(MAKEARGS)

# ------------------------------------------------------------------------------
# EDL Triggering via ADB / Fastboot
# ------------------------------------------------------------------------------

.PHONY: \
	edl-reboot-adb \
	edl-reboot-fastboot

edl-reboot-adb:: edl-check ## Reboot connected Android device into EDL mode via ADB
	@echo "[INFO] Make: Sending 'adb reboot edl'..."
	@$(EDL_DOCKER_RUN) adb reboot edl

edl-reboot-fastboot:: edl-check ## Reboot connected device into EDL mode via Fastboot
	@echo "[INFO] Make: Sending fastboot command to enter EDL..."
	@$(EDL_DOCKER_RUN) fastboot oem edl || $(EDL_DOCKER_RUN) fastboot reboot-edl
