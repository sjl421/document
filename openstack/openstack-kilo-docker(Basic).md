# Openstack(kilo)+Docker 安装指导 #
## 1.环境准备 ##
NO. | IP Header | Host Name | Role | Service | Project Name
----|---------- | --------- | ---- | ------- | ------------
1|10.119.47.106|SIA1000065975|Controller|Dashboard, Identity service, |Horizon, Keystone
2|10.119.41.69|SIA1000065976|Storage|Image service|Glance
3|10.119.39.175|SIA1000065977|Compute|Compute|Nova

>所有密码使用统一密码openstack

## 2.基本环境安装 ##
### 1.安装NTP ###
#### 1.安装和配置Controller ####
```
yum install chrony
vi /etc/chrony.conf
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
allow 10.119.0.0/16
```
开机自启动
```
systemctl enable chronyd.service
systemctl start chronyd.service
```
#### 2.安装配置其他节点 ####
```
yum install chrony
vi /etc/chrony.conf
server SIA1000065975 iburst
```
开机自启动
```
systemctl enable chronyd.service
systemctl start chronyd.service
```
#### 3.验证安装 ####
```
[root@SIA1000065976 ~]# chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^? SIA1000065975                 0  10     0   10y     +0ns[   +0ns] +/-    0ns
```
### 2.安装OpenStack版本仓库 ###
```
yum install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum install http://rdo.fedorapeople.org/openstack-kilo/rdo-release-kilo.rpm
yum upgrade
yum install openstack-selinux
```
# 在Controller Node安装如下服务 #
### 3.安装SQL Database ###
```
yum install mariadb mariadb-server MySQL-python
```
配置MySQL数据库
```
vi /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 10.119.47.106
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
character-set-server = utf8
```
开机自启动
```
systemctl enable mariadb.service
systemctl start mariadb.service
```
初始化数据库
```
mysql_secure_installation
```
### 4.安装Message queue ###
```
yum install rabbitmq-server
```
开机自启动
```
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
```
添加openstack用户
```
rabbitmqctl add_user openstack openstack
```
设置权限
```
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```
