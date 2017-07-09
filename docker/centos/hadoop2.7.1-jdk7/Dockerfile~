FROM centos:latest
MAINTAINER bq-xiao <xbaoqiang@gmail.com>

# env
ENV HADOOP_VERSION 2.7.0

# user and work dir
USER root
WORKDIR /root

# remove old jdk
RUN yum erase -y '*jdk*' '*java*'

# install dev tools 
RUN yum clean all && rpm --rebuilddb
RUN yum install -y curl which tar sudo openssh-server openssh-clients rsync

# download hadoop native support 
RUN mkdir -p /tmp/native
RUN curl -Ls http://172.1.110.100/hadoop-native-64-$HADOOP_VERSION.tar | tar -x -C /tmp/native

# hadoop 
RUN curl -s http://172.1.110.100/hadoop-$HADOOP_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-$HADOOP_VERSION hadoop

# download jdk7
RUN curl -LO "http://172.1.110.100/jdk-7u79-linux-x64.rpm"

# install jdk7
RUN rpm -i jdk-7u79-linux-x64.rpm && rm -f jdk-7u79-linux-x64.rpm

ENV JAVA_HOME /usr/java/default 
ENV PATH $PATH:$JAVA_HOME/bin

ENV HADOOP_PREFIX /usr/local/hadoop 
ENV HADOOP_COMMON_HOME /usr/local/hadoop 
ENV HADOOP_HDFS_HOME /usr/local/hadoop 
ENV HADOOP_MAPRED_HOME /usr/local/hadoop 
ENV HADOOP_YARN_HOME /usr/local/hadoop 
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop 
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop 

# set env
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# change execute
RUN chmod 755 $HADOOP_PREFIX/etc/hadoop/*-env.sh

# enable ssh
RUN systemctl enable sshd.service

# set ssh key file
RUN mkdir /root/.ssh
COPY hadoop.pub /root/
RUN cat hadoop.pub >> /root/.ssh/authorized_keys && rm -f hadoop.pub
RUN chmod 600 /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
COPY hadoop /root/.ssh/id_dsa 
RUN chmod 600 /root/.ssh/id_dsa
RUN chown root:root /root/.ssh/id_dsa
COPY config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# Hdfs ports 
EXPOSE 50010 50020 50070 50075 50090 
# Mapred ports 
EXPOSE 19888 
# Yarn ports 
EXPOSE 8030 8031 8032 8033 8040 8042 8088 
# Other ports .
EXPOSE 49707 22 



