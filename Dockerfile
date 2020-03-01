FROM ubuntu:xenial-20191212

RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  openssh-server \
  openjdk-8-jdk

ARG hadoop_user=hdfs
ARG hadoop_group=hdfs
ARG hadoop_version=3.2.1
ARG hadoop_home=/opt/hadoop

RUN wget -P /tmp http://apache.mirror.serversaustralia.com.au/hadoop/core/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz
RUN tar xzf /tmp/hadoop-${hadoop_version}.tar.gz -C /opt && \
  ln -s /opt/hadoop-${hadoop_version} ${hadoop_home} && \
  rm /tmp/hadoop-${hadoop_version}.tar.gz && \
  chown -R root:root $hadoop_home

RUN addgroup ${hadoop_group} && \
  adduser --ingroup ${hadoop_group} --shell /bin/bash --disabled-password --disabled-login --gecos "" ${hadoop_user}

RUN mkdir /var/log/hadoop && chown ${hadoop_user}:${hadoop_group} /var/log/hadoop && \
  mv ${hadoop_home}/etc/hadoop/hadoop-env.sh ${hadoop_home}/etc/hadoop/hadoop-env.sh.orig && \
  mv ${hadoop_home}/etc/hadoop/core-site.xml ${hadoop_home}/etc/hadoop/core-site.xml.orig && \
  mv ${hadoop_home}/etc/hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml.orig && \
  mv ${hadoop_home}/etc/hadoop/mapred-site.xml ${hadoop_home}/etc/hadoop/mapred-site.xml.orig && \
  mv ${hadoop_home}/etc/hadoop/yarn-site.xml ${hadoop_home}/etc/hadoop/yarn-site.xml.orig

COPY files/hadoop-env.sh ${hadoop_home}/etc/hadoop/hadoop-env.sh
COPY files/core-site.xml ${hadoop_home}/etc/hadoop/core-site.xml
COPY files/hdfs-site.xml ${hadoop_home}/etc/hadoop/hdfs-site.xml
COPY files/mapred-site.xml ${hadoop_home}/etc/hadoop/mapred-site.xml
COPY files/yarn-site.xml ${hadoop_home}/etc/hadoop/yarn-site.xml

RUN ${hadoop_home}/bin/hdfs namenode -format

# AWS S3 jar.  You need to match Hadoop version with the jar files.
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${hadoop_version}/hadoop-aws-${hadoop_version}.jar

# Other jars needed for s3a connectors.
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.11.734/aws-java-sdk-1.11.734.jar
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.11.734/aws-java-sdk-core-1.11.734.jar
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-dynamodb/1.11.734/aws-java-sdk-dynamodb-1.11.734.jar
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.11.734/aws-java-sdk-s3-1.11.734.jar
RUN rm ${hadoop_home}/share/hadoop/common/lib/httpclient* 2>/dev/null &&\
 wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.11/httpclient-4.5.11.jar
RUN wget -P ${hadoop_home}/share/hadoop/common/lib https://repo1.maven.org/maven2/joda-time/joda-time/2.10.5/joda-time-2.10.5.jar

ARG object_store_endpoint=s3.amazonaws.com
ENV OBJECT_STORE_ENDPOINT=${object_store_endpoint}

# HDFS ports.
EXPOSE 9000 9870

# YARN ResourceManager.
EXPOSE 8088

COPY scripts/bootstrap.sh /bootstrap.sh

USER ${hadoop_user}

RUN mkdir -pv /home/${hadoop_user}/.ssh /home/${hadoop_user}/var/run ~/tester
COPY files/sshd_config /home/${hadoop_user}/.ssh/sshd_config

# Allow Setup passphraseless ssh for hadoop_user.
RUN ssh-keygen -t rsa -f ~/.ssh/ssh_host_rsa_key -N '' && \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

# Add Hadoop executables to hadoop_user PATH.
RUN sed -i 's/:$PATH/:\/opt\/hadoop\/bin:$PATH/' ~/.profile

CMD [ "/bootstrap.sh" ]
