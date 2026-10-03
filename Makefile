# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Master Makefile: Automation Toolkit & Root Orchestrator
# Description: Central automation entry point importing modular workflows from .make/*.mk.
# ----------------------------------------------------------------
# Repository: https://github.com/crasivo/shared-make
# Author: Crasivo Dev <crasivodev@gmail.com>
# ----------------------------------------------------------------
# ⚠️ AI AGENT NOTICE / ИНСТРУКЦИЯ ДЛЯ ИИ-АГЕНТОВ:
# RU: Это основной файл проекта (Root Orchestrator).
#     КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО добавлять сюда новые команды и цели!
#     Все команды должны добавляться только в модульные файлы *.mk.
#     Любые изменения данного файла разрешены ИСКЛЮЧИТЕЛЬНО по прямому
#     указанию пользователя вида: "Измени этот файл" ("Modify this file").
# EN: This is the master project orchestrator file.
#     STRICTLY FORBIDDEN to add new commands or targets directly here!
#     All commands must be added into modular *.mk files instead.
#     Modifications are allowed ONLY upon explicit and direct user instruction
#     such as: "Modify this file" ("Измени этот файл").
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SHELL := /bin/bash
MAKEARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEDIR := ${CURDIR}
MAKEFLAGS += --silent

# Define constants
override HOME_DIR         := $(shell realpath ~)
override TMP_DIR          := $(PROJECT_ROOT_DIR)/tmp
override PROJECT_ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
override PROJECT_TMP_DIR  := $(TMP_DIR)
override BACKUP_DATETIME  := $(shell date +'%Y%m%d_%H%M%S')
override BACKUP_DIR       := $(PROJECT_ROOT_DIR)/backups
override CTX_UID          := $(shell id -u)
override CTX_GID          := $(shell id -g)

# Define make directory (.make or make)
ifneq ($(wildcard $(PROJECT_ROOT_DIR)/.make),)
  PROJECT_MAKE_DIR ?= $(PROJECT_ROOT_DIR)/.make
else ifneq ($(wildcard $(PROJECT_ROOT_DIR)/make),)
  PROJECT_MAKE_DIR ?= $(PROJECT_ROOT_DIR)/make
else
  PROJECT_MAKE_DIR ?= $(PROJECT_ROOT_DIR)/.make
endif

# Helper macro to check if a CLI tool exists in system PATH
define check_tool_installed
	@command -v $(1) > /dev/null 2>&1 || { \
		echo "[ERROR] Make: Utility '$(1)' is not installed. Please install it first."; \
		exit 1; \
	}
endef

# Load environments
ifeq ($(wildcard $(PROJECT_ROOT_DIR)/.env),)
  ifneq ($(wildcard $(PROJECT_ROOT_DIR)/.env.example),)
    $(shell cp $(PROJECT_ROOT_DIR)/.env.example $(PROJECT_ROOT_DIR)/.env)
  endif
endif
ifneq ($(wildcard $(PROJECT_ROOT_DIR)/.env),)
  -include $(PROJECT_ROOT_DIR)/.env
  export
endif

# ------------------------------------------------------------------------------
# Help & Documentation Interfaces
# ------------------------------------------------------------------------------

.PHONY: \
	help \
	list

help:: ## Display general usage guide and options
	@echo ""
	@echo -e "\033[1mDESCRIPTION\033[0m"
	@echo -e "  Automation toolkit for managing the project via ready-to-use Make commands."
	@echo ""
	@echo -e "\033[1mUSAGE\033[0m"
	@echo -e "  make <target> [ARGS...]"
	@echo ""
	@echo -e "\033[1mOPTIONS / FLAGS\033[0m"
	@echo -e "  \033[36m--silent, -s\033[0m         Suppress recipe echoing (enabled by default)"
	@echo -e "  \033[36m-n, --dry-run\033[0m        Print commands without executing them"
	@echo -e "  \033[36m-B, --always-make\033[0m    Unconditionally make all targets"
	@echo ""
	@echo -e "\033[1mEXAMPLES\033[0m"
	@echo -e "  make help            Show this general CLI reference manual"
	@echo -e "  make list            Show list of all available tasks with descriptions"
	@echo -e "  make git-status      Display repository status overview"
	@echo -e "  make git-clean       Clean up local Git repository from stale branches"
	@echo ""
	@echo -e "Run '\033[36mmake list\033[0m' to inspect all available targets."
	@echo ""

list:: ## Display this automated help breakdown panel
	@echo "Available project management commands:"
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z0-9_-]+::?.*?## .*$$' | sort | awk 'BEGIN {FS = "::?.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------------------------
# Module Imports & Catch-all Bypass
# ------------------------------------------------------------------------------

# Include home make-modules (*.mk)
-include $(HOME_DIR)/.make/*.mk
-include $(HOME_DIR)/make/*.mk

# Include project make-modules (*.mk)
-include $(PROJECT_ROOT_DIR)/.make/*.mk
-include $(PROJECT_ROOT_DIR)/make/*.mk

# Include context makefiles
-include $(PROJECT_ROOT_DIR)/*/Makefile

# Catch-all rule execution bypass to tolerate loose trailing parameters
%:
	@:
