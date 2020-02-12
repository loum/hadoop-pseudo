#!/bin/sh
set -x

wget -P /tmp http://apache.mirror.serversaustralia.com.au/hadoop/core/hadoop-3.2.1/hadoop-3.2.1.tar.gz 2>&1 | grep -i "failed\|error"
tar xzf /tmp/hadoop-3.2.1.tar.gz -C /opt && chown -R root:root /opt/hadoop-3.2.1
ln -s /opt/hadoop-3.2.1 /opt/hadoop
rm /tmp/hadoop-3.2.1.tar.gz
