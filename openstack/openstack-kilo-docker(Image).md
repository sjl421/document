# Openstack(kilo)+Docker 安装指导 #
## 1.安装Image service ##
### 1.安装过程 ###
#### Controller Node安装过程 ####
#### 1.创建数据库 ####
```
mysql -u root -p
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY 'openstack';
```
#### 2.创建Service ####
```
openstack user create --password-prompt glance
+----------+----------------------------------+
| Field    | Value                            |
+----------+----------------------------------+
| email    | None                             |
| enabled  | True                             |
| id       | c3d3fb5506384af1bc2b2e21d323a768 |
| name     | glance                           |
| username | glance                           |
+----------+----------------------------------+
```
```
openstack role add --project service --user glance admin
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | 6a2fa7c1f4644143a35339a53fde842d |
| name  | admin                            |
+-------+----------------------------------+
```
```
openstack service create --name glance \
  --description "OpenStack Image service" image
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Image service          |
| enabled     | True                             |
| id          | 59a8e511e21840f9a7e281206c0eef9a |
| name        | glance                           |
| type        | image                            |
+-------------+----------------------------------+
```
```
openstack endpoint create \
  --publicurl http://10.119.41.69:9292 \
  --internalurl http://10.119.41.69:9292 \
  --adminurl http://10.119.41.69:9292 \
  --region RegionOne \
  image
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| adminurl     | http://10.119.41.69:9292         |
| enabled      | True                             |
| id           | 2501be124bb246abbc28d545d7669ee4 |
| internalurl  | http://10.119.41.69:9292         |
| publicurl    | http://10.119.41.69:9292         |
| region       | RegionOne                        |
| service_id   | 59a8e511e21840f9a7e281206c0eef9a |
| service_name | glance                           |
| service_type | image                            |
+--------------+----------------------------------+

#### Storage Node安装过程 ####

```
#### 3.安装package ####
```
yum install openstack-glance python-glance python-glanceclient
```
#### 4.配置glance ####
```
vi /etc/glance/glance-api.conf
[database]
connection = mysql://glance:openstack@10.119.41.69/glance

[keystone_authtoken]
auth_uri = http://10.119.41.69:5000
auth_url = http://10.119.41.69:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = openstack

[paste_deploy]
flavor = keystone

[glance_store]
default_store = file
filesystem_store_datadir = /var/lib/glance/images/

[DEFAULT]
notification_driver = noop
verbose = True
```
```
vi /etc/glance/glance-registry.conf
[database]
connection = mysql://glance:openstack@10.119.41.69/glance

[keystone_authtoken]
auth_uri = http://10.119.41.69:5000
auth_url = http://10.119.41.69:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
flavor = keystone

[DEFAULT]
notification_driver = noop
verbose = True
```
#### 5.初始化glance ####
```
su -s /bin/sh -c "glance-manage db_sync" glance
```
#### 5.开机自启动 ####
```
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service
```
### 3.验证 ###
```
echo "export OS_IMAGE_API_VERSION=2" | tee -a admin-openrc.sh demo-openrc.sh
source admin-openrc.sh
mkdir /tmp/images
wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
```
```
glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk.img \
  --disk-format qcow2 --container-format bare --visibility public --progress
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | ee1eca47dc88f4879d8a229cc70a07c6     |
| container_format | bare                                 |
| created_at       | 2016-09-06T09:45:08Z                 |
| disk_format      | qcow2                                |
| id               | ecee5308-40c0-4a1b-b2c6-647696ae5145 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | cirros-0.3.4-x86_64                  |
| owner            | 1a9c9f23900b41389bf8ab06f09df680     |
| protected        | False                                |
| size             | 13287936                             |
| status           | active                               |
| tags             | []                                   |
| updated_at       | 2016-09-06T09:45:09Z                 |
| virtual_size     | None                                 |
| visibility       | public                               |
+------------------+--------------------------------------+
```
```
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
rm -r /tmp/images
```
