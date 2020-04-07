#!/bin/sh

/usr/sbin/sshd -f ~/.ssh/sshd_config

# Start NameNode daemon and DataNode daemon.
/opt/hadoop/sbin/start-dfs.sh

# Start ResourceManager daemon and NodeManager daemon.
/opt/hadoop/sbin/start-yarn.sh

# Block Hadoop until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done
