# Get the name of the project
PROJECT_NAME := $(shell basename $(dir $(realpath $(firstword $(MAKEFILE_LIST)))) | tr A-Z a-z)

# Check if we have python3 available.
PY3_VERSION := $(shell python3 --version 2>/dev/null)
PY3_VERSION_FULL := $(wordlist 2, 4, $(subst ., , ${PY3_VERSION}))
PY3_VERSION_MAJOR := $(word 1, ${PY3_VERSION_FULL})
PY3_VERSION_MINOR := $(word 2, ${PY3_VERSION_FULL})
PY3_VERSION_PATCH := $(word 3, ${PY3_VERSION_FULL})

# python3.3 introduced the venv module which is the
# preferred method for creating python3 virtual envs.
# Otherwise, python3 defaults to pyvenv
USE_PYVENV := $(shell [ ${PY3_VERSION_MINOR} -ge 3 ] && echo 0 || echo 1)
ifneq ($(PY3_VERSION),)
  PY3 := $(shell which python3 2>/dev/null)
  ifeq ($(USE_PYVENV), 1)
    PY_VENV := pyvenv-${PY3_VERSION_MAJOR}.${PY3_VERSION_MINOR}
  else
    PY_VENV := ${PY3} -m venv
  endif
endif

# As long as pip has been installed system-wide, we can use virtualenv
# for python2.
PY2_VENV := $(shell which virtualenv 2>/dev/null)

# Determine virtual env tool to use.
ifeq ($(PYVERSION), 2)
  VENV_TOOL := ${PY2_VENV}
else
  VENV_TOOL := ${PY_VENV}
  PYVERSION := 3
endif

# OK, set some globals.
WHEEL=~/wheelhouse
PYTHONPATH=.
GIT=$(shell which git 2>/dev/null)
HASH=$(shell $(GIT) rev-parse --short HEAD)
SERVICE_NAME=loum/acrta-hive
DOCKER_COMPOSE=$(shell which docker-compose 2>/dev/null || echo "3env/bin/docker-compose")
DOCKER=$(shell which docker 2>/dev/null)
PIP := $(PYVERSION)env/bin/pip
PYTHON := $(PYVERSION)env/bin/python

VENV_DIR_EXISTS := $(shell [ -e "${PYVERSION}env" ] && echo 1 || echo 0)
clear_env:
ifeq ($(VENV_DIR_EXISTS), 1)
	@echo \#\#\# Deleting existing environment ${PYVERSION}env ...
	$(shell which rm) -fr ${PYVERSION}env
	@echo \#\#\# ${PYVERSION}env delete done.
endif

init_env:
	@echo \#\#\# Creating virtual environment ${PYVERSION}env ...
	@echo \#\#\# Using wheel house $(WHEEL) ...
ifneq ($(VENV_TOOL),)
	$(VENV_TOOL) ${PYVERSION}env
	@echo \#\#\# ${PYVERSION}env build done.

	@echo \#\#\# Preparing wheel environment and directory ...
	$(shell which mkdir) -pv $(WHEEL) 2>/dev/null
	$(PIP) install --upgrade pip
	$(PIP) install --upgrade setuptools
	$(PIP) install wheel
	@echo \#\#\# wheel env done.

	@echo \#\#\# Installing package dependencies ...
	$(PIP) wheel --wheel-dir $(WHEEL) --find-links=$(WHEEL) --requirement requirement.txt
	$(PIP) install --find-links=$(WHEEL) --requirement requirement.txt
	@echo \#\#\# Package install done.
else
	@echo \#\#\# Hmmm, cannot find virtual env tool.
	@echo \#\#\# Virtual environment not created.
endif

init: clear_env init_env

py_versions:
	@echo python3 version: ${PY3_VERSION}
	@echo python3 minor: ${PY3_VERSION_MINOR}
	@echo path to python3 executable: ${PY3}
	@echo python3 virtual env command: ${PY_VENV}
	@echo python2 virtual env command: ${PY2_VENV}
	@echo virtual env tooling: ${VENV_TOOL}

print-%:
	@echo '$*=$($*)'

clean:
	$(GIT) clean -xdf -e .vagrant -e *.swp -e 2env -e 3env

local-build-config:
	@SERVICE_NAME=$(SERVICE_NAME) \
      HASH=$(HASH) \
      $(DOCKER_COMPOSE) \
      config

local-build-up: local-build-down
	@SERVICE_NAME=$(SERVICE_NAME) \
      HASH=$(HASH) \
      $(DOCKER_COMPOSE) \
      up -d
	@$(PYTHON) scripts/backoff -p 10000
	@./init.sh

local-build-down:
	@SERVICE_NAME=$(SERVICE_NAME) \
      HASH=$(HASH) \
      $(DOCKER_COMPOSE) \
      down
bi: build-image

build-image:
	@$(DOCKER) build -t $(SERVICE_NAME):$(HASH) .

rmi: rmimage

rm-image:
	@$(DOCKER) rmi $(SERVICE_NAME):$(HASH) || true

rm-dangling-images:
	@$(DOCKER) images -q -f dangling=true && $(DOCKER) rmi $($(DOCKER) images -q -f dangling=true) || true

help:
	@echo "\n \
	Targets\n\
	------------------------------------------------------------------------\n \
	rm-image:             Delete local docker image $(SERVICE_NAME):$(HASH).\n \
	rm-dangling-images:   Remove local dangling docker images.\n \
	print-<var>:          Display the Makefile global variable '<var>' value.\n \
	clean:                Remove all files not tracked by Git.\n \
	";


.PHONY: tests docs py_versions init build upload help clean prebuild
