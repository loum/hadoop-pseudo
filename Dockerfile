ARG HADOOP_VERSION=3.2.1

FROM ubuntu:bionic-20200311 AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends \
 wget\
 ca-certificates

ARG HADOOP_VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -qO- http://apache.mirror.serversaustralia.com.au/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -C /tmp -xzf - 

# AWS S3 jar.  You need to match Hadoop version with the jar files.
RUN mkdir /tmp/jars &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar

# Other jars needed for s3a connectors.
RUN wget -P /tmp/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.734/aws-java-sdk-1.11.734.jar &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.11.734/aws-java-sdk-core-1.11.734.jar &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-dynamodb/1.11.734/aws-java-sdk-dynamodb-1.11.734.jar &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.11.734/aws-java-sdk-s3-1.11.734.jar &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/joda-time/joda-time/2.10.5/joda-time-2.10.5.jar &&\
 wget -P /tmp/jars https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.11/httpclient-4.5.11.jar

### downloader layer end

FROM ubuntu:bionic-20200311

RUN apt-get update && apt-get install -y --no-install-recommends\
 openssh-server=1:7.6p1-4ubuntu0.3\
 openjdk-8-jdk=8u242-b08-0ubuntu3~18.04 &&\
 apt-get clean &&\
 rm -rf /var/lib/apt/lists/*

ARG HADOOP_VERSION
ARG HADOOP_HOME=/opt/hadoop

COPY --from=downloader /tmp/hadoop-${HADOOP_VERSION} /opt/hadoop-${HADOOP_VERSION}
RUN ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} &&\
 chown -R root:root ${HADOOP_HOME}

ARG HADOOP_LIBS=${HADOOP_HOME}/share/hadoop/common/lib
# Remove dated httpclient* jars
RUN rm ${HADOOP_LIBS}/httpclient* 2>/dev/null
COPY --from=downloader /tmp/jars/* ${HADOOP_LIBS}/

ARG HADOOP_USER=hdfs
ARG HADOOP_GROUP=hdfs
RUN addgroup ${HADOOP_GROUP} &&\
 adduser --ingroup ${HADOOP_GROUP} --shell /bin/bash --disabled-password --disabled-login --gecos "" ${HADOOP_USER}

RUN mkdir /var/log/hadoop && chown ${HADOOP_USER}:${HADOOP_GROUP} /var/log/hadoop &&\
 mv ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh.orig &&\
 mv ${HADOOP_HOME}/etc/hadoop/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml.orig &&\
 mv ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml.orig &&\
 mv ${HADOOP_HOME}/etc/hadoop/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml.orig &&\
 mv ${HADOOP_HOME}/etc/hadoop/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml.orig

COPY files/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
COPY files/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
COPY files/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
COPY files/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
COPY files/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml

RUN ${HADOOP_HOME}/bin/hdfs namenode -format

ARG object_store_endpoint=s3.amazonaws.com
ENV OBJECT_STORE_ENDPOINT=${object_store_endpoint}

# Hadoop NameNode port.
EXPOSE 9000

# Hadoop NameNode web UI.
EXPOSE 9870

# YARN ResourceManager web UI.
EXPOSE 8088

# MapReduce JobHistory Server web UI.
EXPOSE 19888

COPY scripts/hadoop-bootstrap.sh /hadoop-bootstrap.sh

USER ${HADOOP_USER}
WORKDIR /home/${HADOOP_USER}

RUN mkdir -pv .ssh var/run
COPY files/sshd_config .ssh/sshd_config

# Allow Setup passphraseless ssh for hadoop_user.
RUN ssh-keygen -t rsa -f .ssh/ssh_host_rsa_key -N '' &&\
 ssh-keygen -t rsa -P '' -f .ssh/id_rsa &&\
 cat ~/.ssh/id_rsa.pub >> .ssh/authorized_keys &&\
 chmod 0600 .ssh/authorized_keys

# Add Hadoop executables to HADOOP_USER PATH.
RUN echo export PATH="${HADOOP_HOME}/bin:$PATH" >> .bashrc

CMD [ "/hadoop-bootstrap.sh" ]
