# 一． Proxy #
```
vi /etc/profile.d/proxy.sh
http_proxy=http://user:password@proxy.huawei.com:8080/
https_proxy=http:// user: password@proxy.huawei.com:8080/
export http_proxy https_proxy
```
# 二． update OS #
```yum update -y```
# 三． yum repo #
```
vi /etc/yum.repos.d/docker-main.repo
[docker-main-repo]
name=Docker main Repository
baseurl=http://yum.dockerproject.org/repo/main/centos/$releasever
enabled=1
gpgcheck=1
gpgkey=http://yum.dockerproject.org/gpg
```
# 四． install docker #
```yum install docker-engine -y```
# 五． docker proxy #
```
vi /etc/sysconfig/docker
HTTP_PROXY=http://user:password@proxy.huawei.com:8080/
HTTPS_PROXY=http://user:password@proxy.huawei.com:8080/
export HTTP_PROXY HTTPS_PROXY
```
# 六． 验证 #
```
docker pull hello-world
docker run hello-world
Hello from Docker.
This message shows that your installation appears to be working correctly.
```
# 七． Swarm实验 #
## 1.环境centos6：##
| role | host name | ip |
|----------|---------------|--------------|
| manager0 | SIA1000065975 | 10.119.47.106|
| node0 | SIA1000065975 | 10.119.47.106 |
| node1 | SIA1000065976 | 10.119.41.69 |
| node2 | SIA1000065977 | 10.119.39.175 |
| consul0 | SIA1000065975 | 10.119.47.106 |

## 2.命令：##
```
A.manager0:
docker run -d --name manager-master -p 4000:4000 swarm manage -H :4000 --replication --advertise 10.119.47.106:4000 consul://10.119.47.106:8500
B. node0:
docker run -d --name node0 swarm join --advertise=10.119.47.106:2375 consul://10.119.47.106:8500
C.node1:
docker run -d --name node1 swarm join --advertise=10.119.41.69:2375 consul://10.119.47.106:8500
D.node2:
docker run -d --name node2 swarm join --advertise=10.119.39.175:2375 consul://10.119.47.106:8500
C.consul0:
docker run -d -p 8500:8500 --name=consul progrium/consul -server –bootstrap
```
# 八． 验证：#
```
manager0执行命令：docker –H :4000 info
```
# 九. kubernetes实验 #
## 1.环境centos7 ##
| role | host name | ip |
|----------|---------------|--------------|
| master | SIA1000065975 | 10.119.47.106 |
| node0 | SIA1000065975 | 10.119.47.106 |
| node1 | SIA1000065976 | 10.119.41.69 |
| node2 | SIA1000065977 | 10.119.39.175 |

**centos6升级centos7，参考：https://wiki.centos.org/zh/TipsAndTricks/CentOSUpgradeTool**
## 2.配置master免密码登陆node1，node2 ##
### A．master命令：###
```
ssh-keygen -t rsa		---<三次回车>
scp .ssh/id_rsa.pub root@10.119.41.69:/root/ id_rsa.pub
scp .ssh/id_rsa.pub root@10.119.39.175:/root/ id_rsa.pub
```
### B．node1和node2分别执行命令：###
```
cat id_rsa.pub >> .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```
### C．验证 ###
```
master ssh登陆node1，node2
```
## 3.配置kubernetes源 ##
### master执行命令：###
```
vi /etc/yum.repos.d/virt7-docker-common-release.repo
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
scp /etc/yum.repos.d/virt7-docker-common-release.repo root@10.119.41.69:/etc/yum.repos.d/virt7-docker-common-release.repo
scp /etc/yum.repos.d/virt7-docker-common-release.repo root@10.119.39.175:/etc/yum.repos.d/virt7-docker-common-release.repo
```
## 4.安装 ##
参考官方手册：http://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/
