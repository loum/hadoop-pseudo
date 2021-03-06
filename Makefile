.DEFAULT_GOAL := help

MAKESTER__REPO_NAME := loum

HADOOP_VERSION := 3.2.2

# Tagging convention used: <hadoop-version>-<image-release-number>
MAKESTER__VERSION = $(HADOOP_VERSION)
MAKESTER__RELEASE_NUMBER = 1

include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

UBUNTU_BASE_IMAGE := focal-20210609
OPENJDK_8_HEADLESS := 8u292-b10-0ubuntu1~20.04
OPENSSH_SERVER := 1:8.2p1-4ubuntu0.2

MAKESTER__BUILD_COMMAND = $(DOCKER) build --rm\
 --no-cache\
 --build-arg HADOOP_VERSION=$(HADOOP_VERSION)\
 --build-arg UBUNTU_BASE_IMAGE=$(UBUNTU_BASE_IMAGE)\
 --build-arg OPENJDK_8_HEADLESS=$(OPENJDK_8_HEADLESS)\
 --build-arg OPENSSH_SERVER=$(OPENSSH_SERVER)\
 -t $(MAKESTER__IMAGE_TAG_ALIAS) .

MAKESTER__CONTAINER_NAME := hadoop-pseudo
MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --publish 9000:9000\
 --publish 9870:9870\
 --publish 8088:8088\
 --publish 19888:19888\
 $(MAKESTER__SERVICE_NAME):$(HASH)

MAKESTER__IMAGE_TARGET_TAG = $(HASH)

init: clear-env makester-requirements

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Hadoop NameNode port" -p 9000 localhost
	@$(PYTHON) makester/scripts/backoff -d "Hadoop NameNode web UI port" -p 9870 localhost
	@$(PYTHON) makester/scripts/backoff -d "YARN ResourceManager web UI port" -p 8088 localhost
	@$(PYTHON) makester/scripts/backoff -d "MapReduce JobHistory Server web UI port" -p 19888 localhost

controlled-run: run backoff

login:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true

hadoop-version:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) /opt/hadoop/bin/hadoop version || true

help: makester-help docker-help python-venv-help
	@echo "(Makefile)\n\
  login                Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n\
  hadoop-version       Hadoop version in running container $(MAKESTER__CONTAINER_NAME)\"\n"

.PHONY: help
