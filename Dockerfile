FROM ubuntu:xenial-20191212

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  wget \
  openssh-server \
  openjdk-8-jdk

# Harden sshd.
RUN mkdir /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#UsePAM no/UsePAM yes/' /etc/ssh/sshd_config

ARG hadoop_user=hdfs
ARG hadoop_group=hdfs

RUN wget -P /tmp http://apache.mirror.serversaustralia.com.au/hadoop/core/hadoop-3.2.1/hadoop-3.2.1.tar.gz
RUN tar xzf /tmp/hadoop-3.2.1.tar.gz -C /opt && \
  ln -s /opt/hadoop-3.2.1 /opt/hadoop && \
  rm /tmp/hadoop-3.2.1.tar.gz && \
  chown -R root:root /opt/hadoop

RUN addgroup $hadoop_group && \
  adduser --ingroup $hadoop_group --shell /bin/bash --disabled-password --disabled-login --gecos "" $hadoop_user

RUN mkdir /var/log/hadoop && chown $hadoop_user:$hadoop_group /var/log/hadoop

# Allow Setup passphraseless ssh for hadoop_user.
USER $hadoop_user
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

# Add Hadoop executables to hadoop_user PATH.
RUN sed -i 's/:$PATH/:\/opt\/hadoop\/bin:$PATH/' ~/.profile

USER root
RUN mv /opt/hadoop/etc/hadoop/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh.orig
COPY files/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh

RUN mv /opt/hadoop/etc/hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml.orig
COPY files/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml

RUN mv /opt/hadoop/etc/hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml.orig
COPY files/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

RUN mv /opt/hadoop/etc/hadoop/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xml.orig
COPY files/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xml

RUN mv /opt/hadoop/etc/hadoop/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml.orig
COPY files/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml

RUN /opt/hadoop/bin/hdfs namenode -format

COPY scripts/bootstrap.sh /bootstrap.sh
CMD [ "/bootstrap.sh" ]

# HDFS ports.
EXPOSE 9000 9870

# YARN ResourceManager.
EXPOSE 8088
