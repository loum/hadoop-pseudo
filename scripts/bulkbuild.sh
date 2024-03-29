#!/bin/sh
#
LATEST_HADOOP_VERSION=$HADOOP_VERSION

for HADOOP_VERSION in 3.3.1 3.3.2 3.3.3 3.3.4 3.3.5 3.3.6
do
    CMD="docker buildx build --platform linux/arm64,linux/amd64
 --push --rm --no-cache
 --build-arg UBUNTU_BASE_IMAGE=$UBUNTU_BASE_IMAGE
 --build-arg HADOOP_VERSION=$HADOOP_VERSION
 --build-arg OPENSSH_SERVER=$OPENSSH_SERVER"

    if [ "$HADOOP_VERSION" = "$LATEST_HADOOP_VERSION" ]
    then
        CMD="$CMD --tag loum/hadoop-pseudo:latest"
    fi

    CMD="$CMD --tag loum/hadoop-pseudo:$HADOOP_VERSION ."

    $CMD
done
