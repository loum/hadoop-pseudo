#!/bin/sh

/usr/sbin/sshd -f /home/hdfs/.ssh/sshd_config

if [ -z "$MAPRED_SITE__MAPREDUCE_FRAMEWORK_NAME" ]; then
    export MAPRED_SITE__MAPREDUCE_FRAMEWORK_NAME=yarn
fi

if [ -z "$CORE_SITE__FS_DEFAULTFS" ]; then
    export CORE_SITE__FS_DEFAULTFS="hdfs://0.0.0.0:9000"
    export CORE_SITE__FS_DEFAULT_NAME="hdfs://0.0.0.0:9000"
fi

# Generate the configs from environment settinss.
python /config-setter.py -t "/opt/hadoop/etc/hadoop/hdfs-site.xml.j2" -T "HDFS_SITE__"
python /config-setter.py -t "/opt/hadoop/etc/hadoop/yarn-site.xml.j2" -T "YARN_SITE__"
python /config-setter.py -t "/opt/hadoop/etc/hadoop/mapred-site.xml.j2" -T "MAPRED_SITE__"
python /config-setter.py -t "/opt/hadoop/etc/hadoop/core-site.xml.j2" -T "CORE_SITE__"

if [ "$NAMENODE_FORMAT_FORCE" = "true" ]; then
    /opt/hadoop/bin/hdfs namenode -format -force
else
    /opt/hadoop/bin/hdfs namenode -format << EOF
N
EOF
fi

# Start NameNode daemon and DataNode daemon.
/opt/hadoop/sbin/start-dfs.sh

# Start ResourceManager daemon and NodeManager daemon.
/opt/hadoop/sbin/start-yarn.sh

# Start MapReduce JobHistory Server daemon.
/opt/hadoop/bin/mapred --daemon start historyserver

# Block Hadoop until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done
