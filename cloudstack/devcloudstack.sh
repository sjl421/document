#!/bin/bash

# Ubuntu 12.04

# update and upgrade system
sudo apt-get update -y && sudo apt-get upgrade -y

# install system dependence
sudo apt-get install -y openntpd openjdk-7-jdk tomcat6 mysql-server git maven python-pip python-setuptools genisoimage
sleep 3s

# echo version
echo "maven version:"
mvn --version

# clone source
git clone https://git-wip-us.apache.org/repos/asf/cloudstack.git cloudstack
git checkout 4.8

# compile Apache CloudStack
cd cloudstack
mvn -Pdeveloper,systemvm clean install -DskipTests
sleep 3s
mvn -P developer -pl developer -Ddeploydb -DskipTests

# Run Apache CloudStack with jetty
mvn -pl :cloud-client-ui jetty:run
