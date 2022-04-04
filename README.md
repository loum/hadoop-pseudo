# Hadoop: Pseudo Distributed on Docker
- [Overview](#Overview)
- [Quick Links](#Quick-Links)
- [Quick Start](#Quick-Start)
- [Prerequisites](#Prerequisites)
- [Getting Started](#Getting-Started)
- [Getting Help](#Getting-Help)
- [Docker Image Management](#Docker-Image-Management)
  - [Image Build](#Image-Build)
    - [Configuration](#Configuration)
  - [Image Searches](#Image-Searches)
  - [Image Tagging](#Image-Tagging)
- [Interact with Hadoop](#Interact-with-Hadoop)
- [Web Interfaces](#Web-Interfaces)

## Overview
Quick and easy way to get Hadoop running in [pseudo-distributed](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html#Pseudo-Distributed_Operation) mode using [Docker](https://docs.docker.com/install/).

Docker image is based on [Ubuntu Focal 20.04 LTS](https://hub.docker.com/_/ubuntu?tab=description).

See [Hadoop docs](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html#Configuration) for more information.
## Quick Links
- [Hadoop 3.2.2](https://hadoop.apache.org/release/3.2.2.html)

## Quick Start
Impatient and just want Hadoop quickly?:
```
docker run --rm -ti --name hadoop-pseudo loum/hadoop-pseudo:latest
```
> **_NOTE:_** More at https://hub.docker.com/r/loum/hadoop-pseudo

## Prerequisites
- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)

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
## Getting Help
There should be a `make` target to get most things done.  Check the help for more information:
```
make help
```
## Docker Image Management
### Image Build
When you are ready to build the image:
```
make build-image
```
#### Configuration
Every Hadoop configuration setting can be overridden during container startup by targeting the setting name and prepending the configuration file context as per the following:
- [Hadoop core-default.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml) | Override with `CORE_SITE__<setting>`
- [Hadoop hdfs-default.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml) | Override token `HDFS_SITE__<setting>`
- [Hadoop mapred-default.xml](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml) | Override with `MAPRED_SITE__<setting>`
- [Hadoop yarn-default.xml](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml) | Override with `YARN_SITE__<setting>`

### Image Searches
Search for existing Docker image tags with command:
```
make search-image
```
### Image Tagging
By default, `makester` will tag the new Docker image with the current branch hash.  This provides a degree of uniqueness but is not very intuitive.  That's where the `tag-version` `Makefile` target can help.  To apply tag as per project tagging convention `<hadoop-version>-<image-release-number>`
```
make tag-version
```
To tag the image as `latest`
```
make tag-latest
```
## Interact with Hadoop
To start the container and wait for all Hadoop services to initiate:
```
make controlled-run
```
Run `hadoop` as the `hdfs` user:
```
docker exec hadoop-pseudo /opt/hadoop/bin/hdfs version
```
Check the [Hadoop Command Reference](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html) for more.

To stop:
```
make stop
```
## Web Interfaces
The following web interfaces are available to view configurations and logs:
- Hadoop NameNode web UI: http://localhost:9870
- YARN ResourceManager web UI: http://localhost:8088
- MapReduce JobHistory Server web UI: http://localhost:19888

[top](#Hadoop:-Pseudo-Distributed-on-Docker)
