# Hadoop: Pseudo Distributed Container Image

- [Overview](#overview)
- [Quick Links](#quick-links)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Getting Help](#getting-help)
- [Docker Image Management](#docker-image-management)
- [Interact with Hadoop](#interact-with-hadoop)
  - [Configuration](#configuration)
  - [Container runtime](#container-runtime)
  - [Web interfaces](#web-interfaces)

## Overview
Quick and easy way to get Hadoop running in [pseudo-distributed](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html#Pseudo-Distributed_Operation) mode using [Docker](https://docs.docker.com/install/).

See [Hadoop docs](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Configuration) for more information.

[top](#hadoop-pseudo-distributed-container-image)

## Quick Links
- [Hadoop Pseudo Distributed](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)

[top](#hadoop-pseudo-distributed-container-image)

## Quick Start
Impatient, and just want Hadoop quickly?:
```
docker run --rm -ti --name hadoop-pseudo loum/hadoop-pseudo:latest
```
> **_NOTE:_** More at https://hub.docker.com/r/loum/hadoop-pseudo

[top](#hadoop-pseudo-distributed-container-image)

## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)
- Python 3 Interpreter. [We recommend installing pyenv](https://github.com/pyenv/pyenv).

[top](#hadoop-pseudo-distributed-container-image)

## Getting Started
Get the code and change into the top level `git` project directory:
```
git clone https://github.com/loum/hadoop-pseudo.git && cd hadoop-pseudo
```
> **_NOTE:_** Run all commands from the top-level directory of the `git` repository.

For first-time setup, prime the [Makester project](https://github.com/loum/makester.git):
```
git submodule update --init
```

Keep [Makester project](https://github.com/loum/makester.git) up-to-date with:
```
make submodule-update
```

Setup the environment:
```
make init
```

[top](#hadoop-pseudo-distributed-container-image)

## Getting Help
There should be a `make` target to get most things done.  Check the help for more information:
```
make help
```

[top](#hadoop-pseudo-distributed-container-image)

## Docker Image Management
> **_NOTE:_**  See [Makester's `docker` subsystem](https://loum.github.io/makester/makefiles/docker/) for more detailed container image operations.

Build the container image locally:
```
make image-build
```

Search for built container image:
```
make image-search
```

Delete the container image:
```
make image-rm
```

[top](#hadoop-pseudo-distributed-container-image)

## Interact with Hadoop

### Configuration
Every Hadoop configuration setting can be overridden during container startup by targeting the setting name and prepending the configuration file context as per the following:
- [Hadoop core-default.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml) | Override with `CORE_SITE__<setting>`
- [Hadoop hdfs-default.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml) | Override token `HDFS_SITE__<setting>`
- [Hadoop mapred-default.xml](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml) | Override with `MAPRED_SITE__<setting>`
- [Hadoop yarn-default.xml](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml) | Override with `YARN_SITE__<setting>`

### Container runtime
To start the container and wait for all Hadoop services to initiate:
```
make controlled-run
```

Get the Hadoop version:
```
make hadoop-version
```

To drop into the container runtime's shell and interact with `hdfs`:
```
make container-bash
```

 **_NOTE:_** The [Hadoop Command Reference](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html) details the full command suite.

Stop the running container image:
```
make container-stop
```

### Web interfaces
The following web interfaces are available to view configurations and logs:
- Hadoop NameNode web UI: http://localhost:9870
- YARN ResourceManager web UI: http://localhost:8088
- MapReduce JobHistory Server web UI: http://localhost:19888

[top](#hadoop-pseudo-distributed-container-image)
