# Openstack(kilo)+Docker 安装指导 #
## 1.安装Nova + Docker ##
安装过程在Compute Node进行
### 1.项目路径 ###
[Nova + Docker](https://github.com/openstack/nova-docker)
### 2.下载Release版本 ###
```
wget https://codeload.github.com/openstack/nova-docker/tar.gz/kilo-eol
```
### 3.安装pip ###
```
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com pip -U
```
### 4.安装nova-docker ###
```
tar -zxvf nova-docker-kilo-eol.tar.gz
cd nova-docker-kilo-eol
pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com -r requirements.txt
python setup.py install
```
### 5.配置Nova ###
```
vi /etc/nova/nova.conf
compute_driver=novadocker.virt.docker.DockerDriver

[docker]
# Commented out. Uncomment these if you'd like to customize:
## vif_driver=novadocker.virt.docker.vifs.DockerGenericVIFDriver
## snapshots_directory=/var/tmp/my-snapshot-tempdir
```
### 5.配置Glance ###
```
vi /etc/glance/glance-api.conf
container_formats=ami,ari,aki,bare,ovf,ova,docker
```
### 6.上传Image到Glance ###
```
docker pull busybox
docker save busybox | openstack image create busybox --public --container-format docker --disk-format raw
```
```
docker pull nginx
docker save nginx | glance image-create --name "nginx" --visibility public --progress --container-format docker --disk-format raw
```
### 7.更新Image ###
```
source admin-openrc.sh
glance image-list
+--------------------------------------+---------------------+
| ID                                   | Name                |
+--------------------------------------+---------------------+
| 7d05df9f-1435-4aea-ab97-5e6e5aec3be8 | busybox             |
| ecee5308-40c0-4a1b-b2c6-647696ae5145 | cirros-0.3.4-x86_64 |
| ee2fea6e-1c00-42e1-ae5f-c91b944bea06 | nginx               |
+--------------------------------------+---------------------+
```
```
glance image-update --property os_command_line='/usr/sbin/sshd -D' 7d05df9f-1435-4aea-ab97-5e6e5aec3be8
```
```
glance image-show 7d05df9f-1435-4aea-ab97-5e6e5aec3be8
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | 42d231aeb62b9f7df0d8fc05a2ccd623     |
| container_format | docker                               |
| created_at       | 2016-09-06T09:46:04Z                 |
| disk_format      | raw                                  |
| id               | 7d05df9f-1435-4aea-ab97-5e6e5aec3be8 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | busybox                              |
| os_command_line  | /usr/sbin/sshd -D                    |
| owner            | 1a9c9f23900b41389bf8ab06f09df680     |
| protected        | False                                |
| size             | 1302016                              |
| status           | active                               |
| tags             | []                                   |
| updated_at       | 2016-09-06T09:46:34Z                 |
| virtual_size     | None                                 |
| visibility       | public                               |
+------------------+--------------------------------------+
```
### 8.创建keypair ###
```
nova keypair-add mykey > mykey.pem
+-------+-------------------------------------------------+
| Name  | Fingerprint                                     |
+-------+-------------------------------------------------+
| mykey | 61:e0:7e:5d:0c:d1:4d:eb:73:f9:75:70:4d:16:99:8f |
+-------+-------------------------------------------------+
```
### 9.启动容器 ###
```
nova boot --flavor m1.small --image nginx nginxtest
```
### 10.验证 ###
```
nova list
+--------------------------------------+-----------+--------+------------+-------------+----------+
| ID                                   | Name      | Status | Task State | Power State | Networks |
+--------------------------------------+-----------+--------+------------+-------------+----------+
| fa326f71-a831-4ccd-8b83-074ee841d5eb | nginxtest | ACTIVE | -          | Running     |          |
+--------------------------------------+-----------+--------+------------+-------------+----------+
```
