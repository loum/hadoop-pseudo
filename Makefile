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

rm-image:
	@$(DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH) || true

help: base-help docker-help
	@echo "(Makefile)\n\
  build-image:         Build docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
  rm-image:            Delete docker image $(MAKESTER__SERVICE_NAME):$(HASH)\n\
	";

.PHONY: help
