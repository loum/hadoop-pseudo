# Include overrides (must occur before include statements).
MAKESTER__CONTAINER_NAME := hadoop-pseudo

include makester/makefiles/base.mk
include makester/makefiles/docker.mk

MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

bi: build-image

build-image:
	@$(DOCKER) build -t $(MAKESTER__SERVICE_NAME):$(HASH) .

rmi: rm-image

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

login:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash || true

hadoop-version:
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) /opt/hadoop/bin/hadoop version || true

help: base-help docker-help
	@echo "(Makefile)\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias bi)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH) (alias rmi)\n\
  login:               Login to container $(MAKESTER__CONTAINER_NAME) as user \"hdfs\"\n\
  hadoop-version:      Hadoop version in running container $(MAKESTER__CONTAINER_NAME)\"\n\
	";

.PHONY: help
