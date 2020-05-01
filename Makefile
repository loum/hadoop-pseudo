include makester/makefiles/base.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

MAKESTER__REPO_NAME = loum
MAKESTER__CONTAINER_NAME = hadoop-pseudo

MAKESTER__VERSION = 3.2.1
MAKESTER__RELEASE_NUMBER = 3

MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --publish 9000:9000\
 --publish 9870:9870\
 --publish 8088:8088\
 --publish 19888:19888\
 $(MAKESTER__SERVICE_NAME):$(HASH)

MAKESTER__IMAGE_TARGET_TAG = $(HASH)

init: makester-requirements

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

vars:
	@$(MAKE) -s print-MAKESTER__REPO_NAME\
 print-MAKESTER__IMAGE_TAG_ALIAS\
 print-MAKESTER__SERVICE_NAME\
 print-MAKESTER__VERSION\
 print-MAKESTER__RELEASE_NUMBER

help: base-help docker-help python-venv-help
	@echo "(Makefile)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n\
  hadoop-version:      Hadoop version in running container $(MAKESTER__CONTAINER_NAME)\"\n\
	";

.PHONY: help
