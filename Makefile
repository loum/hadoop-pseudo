.DEFAULT_GOAL := help

MAKESTER__INCLUDES := py docker versioning
MAKESTER__REPO_NAME := loum

include makester/makefiles/makester.mk

#
# Makester overrides.
#
# Container image build.
HADOOP_VERSION := 3.3.4
UBUNTU_BASE_IMAGE := loum/pyjdk:python3.10-openjdk11
OPENSSH_SERVER := 1:8.9p1-3ubuntu0.1

# Tagging convention used: <hadoop-version>-<image-release-number>
MAKESTER__VERSION := $(HADOOP_VERSION)
MAKESTER__RELEASE_NUMBER := 1

MAKESTER__IMAGE_TARGET_TAG := $(MAKESTER__RELEASE_VERSION)

MAKESTER__BUILD_COMMAND = --rm --no-cache\
 --build-arg HADOOP_VERSION=$(HADOOP_VERSION)\
 --build-arg UBUNTU_BASE_IMAGE=$(UBUNTU_BASE_IMAGE)\
 --build-arg OPENSSH_SERVER=$(OPENSSH_SERVER)\
 -t $(MAKESTER__IMAGE_TAG_ALIAS) .

MAKESTER__CONTAINER_NAME := hadoop-pseudo
MAKESTER__RUN_COMMAND := $(MAKESTER__DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --env HDFS_SITE__DFS_REPLICATION=1\
 --publish 9000:9000\
 --publish 9870:9870\
 --publish 8088:8088\
 --publish 19888:19888\
 $(MAKESTER__IMAGE_TAG_ALIAS)

#
# Local Makefile targets.
#
# Initialise the development environment.
init: py-venv-clear py-venv-init py-install-makester

backoff:
	@venv/bin/makester backoff $(MAKESTER__LOCAL_IP) 9000 --detail "Hadoop NameNode port"
	@venv/bin/makester backoff $(MAKESTER__LOCAL_IP) 9870 --detail "Hadoop NameNode web UI port"
	@venv/bin/makester backoff $(MAKESTER__LOCAL_IP) 8088 --detail "YARN ResourceManager web UI port"
	@venv/bin/makester backoff $(MAKESTER__LOCAL_IP) 19888 --detail "MapReduce JobHistory Server web UI port"

controlled-run: container-run backoff

hadoop-version:
	@$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) /opt/hadoop/bin/hadoop version || true

help: makester-help
	@echo "(Makefile)\n\
  controlled-run       Start container \"$(MAKESTER__CONTAINER_NAME)\" on $(MAKESTER__IMAGE_TAG_ALIAS) and wait for all Hadoop services\n\
  hadoop-version       Display the Hadoop version in running container \"$(MAKESTER__CONTAINER_NAME)\"\n\
  init                 Build the local development environment\n"

.PHONY: help
