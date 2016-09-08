# Openstack(kilo)+Docker 安装指导 #
## 1.安装Compute service ##
### Controller Node安装过程 ###
### 1.安装过程 ###
#### 1.创建数据库 ####
```
mysql -u root -p
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY 'openstack';
```
#### 2.创建Service ####
```
source admin-openrc.sh
```
```
openstack user create --password-prompt nova
+----------+----------------------------------+
| Field    | Value                            |
+----------+----------------------------------+
| email    | None                             |
| enabled  | True                             |
| id       | 6f62c9630ae2492eaaef001e5e3244bd |
| name     | nova                             |
| username | nova                             |
+----------+----------------------------------+
```
```
openstack role add --project service --user nova admin
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | a319b8fadb664d268a464a99cef0dc5e |
| name  | user                             |
+-------+----------------------------------+
```
```
openstack service create --name nova \
  --description "OpenStack Compute" compute
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Compute                |
| enabled     | True                             |
| id          | 09087f1d95a542758f7fa41c9191a080 |
| name        | nova                             |
| type        | compute                          |
+-------------+----------------------------------+
```
```
openstack endpoint create \
--publicurl http://10.119.41.69:9292/v2/%\(tenant_id\)s \
--internalurl http://10.119.41.69:9292/v2/%\(tenant_id\)s \
--adminurl http://10.119.41.69:9292/v2/%\(tenant_id\)s \
--region RegionOne \
compute
+--------------+--------------------------------------------+
| Field        | Value                                      |
+--------------+--------------------------------------------+
| adminurl     | http://10.119.39.175:8774/v2/%(tenant_id)s |
| enabled      | True                                       |
| id           | bfc8aecfc1154c8fb1d7e57e6e4d8f1b           |
| internalurl  | http://10.119.39.175:8774/v2/%(tenant_id)s |
| publicurl    | http://10.119.39.175:8774/v2/%(tenant_id)s |
| region       | RegionOne                                  |
| service_id   | 09087f1d95a542758f7fa41c9191a080           |
| service_name | nova                                       |
| service_type | compute                                    |
+--------------+--------------------------------------------+
```
#### 3.安装package ####
```
yum install openstack-nova-api openstack-nova-cert openstack-nova-conductor \
  openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler \
  python-novaclient
```
#### 4.配置nova ####
```
vi /etc/nova/nova.conf
[database]
connection = mysql://nova:openstack@10.119.39.175/nova

[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
my_ip = 10.119.47.106
vncserver_listen = 10.119.47.106
vncserver_proxyclient_address = 10.119.47.106
verbose = True

[oslo_messaging_rabbit]
rabbit_host = 10.119.39.175
rabbit_userid = openstack
rabbit_password = openstack

[keystone_authtoken]
auth_uri = http://10.119.39.175:5000
auth_url = http://10.119.39.175:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = openstack

[glance]
host = 10.119.39.175

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
```
#### 5.初始化nova ####
```
su -s /bin/sh -c "nova-manage db sync" nova
```
#### 5.开机自启动 ####
```
systemctl enable openstack-nova-api.service openstack-nova-cert.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service

systemctl start openstack-nova-api.service openstack-nova-cert.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service
```
### Compute Node安装过程 ###
#### 1.安装过程 ####
```
yum install openstack-nova-compute sysfsutils
```
#### 2.配置nova ####
```
vi /etc/nova/nova.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
my_ip = 10.119.39.175
vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = 10.119.39.175
novncproxy_base_url = http://10.119.47.106:6080/vnc_auto.html
verbose = True

[oslo_messaging_rabbit]
rabbit_host = 10.119.47.106
rabbit_userid = openstack
rabbit_password = openstack

[keystone_authtoken]
auth_uri = http://10.119.47.106:5000
auth_url = http://10.119.47.106:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = openstack

[glance]
host = 10.119.47.106

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[libvirt]
virt_type = qemu
```
#### 3.开机自启动 ####
```
systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service
```
#### 4.验证 ####
```
nova service-list
+----+------------------+---------------+----------+---------+-------+----------------------------+-----------------+
| Id | Binary           | Host          | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----+------------------+---------------+----------+---------+-------+----------------------------+-----------------+
| 1  | nova-consoleauth | SIA1000065977 | internal | enabled | up    | 2016-09-08T03:51:40.000000 | -               |
| 2  | nova-scheduler   | SIA1000065977 | internal | enabled | up    | 2016-09-08T03:51:40.000000 | -               |
| 3  | nova-cert        | SIA1000065977 | internal | enabled | up    | 2016-09-08T03:51:41.000000 | -               |
| 4  | nova-conductor   | SIA1000065977 | internal | enabled | up    | 2016-09-08T03:51:40.000000 | -               |
| 5  | nova-compute     | SIA1000065977 | nova     | enabled | up    | 2016-09-08T03:51:33.000000 | -               |
| 6  | nova-network     | SIA1000065977 | internal | enabled | up    | 2016-09-08T03:51:36.000000 | -               |
+----+------------------+---------------+----------+---------+-------+----------------------------+-----------------+
```
```
nova endpoints
+-----------+---------------------------------------------------------------+
| nova      | Value                                                         |
+-----------+---------------------------------------------------------------+
| id        | c49c219800ca48e8b2458cf341f96ac5                              |
| interface | public                                                        |
| region    | RegionOne                                                     |
| region_id | RegionOne                                                     |
| url       | http://10.119.39.175:8774/v2/1a9c9f23900b41389bf8ab06f09df680 |
+-----------+---------------------------------------------------------------+
+-----------+---------------------------------------------------------------+
| nova      | Value                                                         |
+-----------+---------------------------------------------------------------+
| id        | d50e764e606d46ecaa64145db0fc206d                              |
| interface | internal                                                      |
| region    | RegionOne                                                     |
| region_id | RegionOne                                                     |
| url       | http://10.119.39.175:8774/v2/1a9c9f23900b41389bf8ab06f09df680 |
+-----------+---------------------------------------------------------------+
+-----------+---------------------------------------------------------------+
| nova      | Value                                                         |
+-----------+---------------------------------------------------------------+
| id        | f531919829e34c60a4d36f45a761c53d                              |
| interface | admin                                                         |
| region    | RegionOne                                                     |
| region_id | RegionOne                                                     |
| url       | http://10.119.39.175:8774/v2/1a9c9f23900b41389bf8ab06f09df680 |
+-----------+---------------------------------------------------------------+
+-----------+----------------------------------+
| glance    | Value                            |
+-----------+----------------------------------+
| id        | 33dcb55920a04071ae70bf0b30157eb3 |
| interface | internal                         |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.41.69:9292         |
+-----------+----------------------------------+
+-----------+----------------------------------+
| glance    | Value                            |
+-----------+----------------------------------+
| id        | 5f6842c3b1d04d2292dc0aa500615b96 |
| interface | admin                            |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.41.69:9292         |
+-----------+----------------------------------+
+-----------+----------------------------------+
| glance    | Value                            |
+-----------+----------------------------------+
| id        | 869d417ed9aa4408ae3c05bc1cd534e8 |
| interface | public                           |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.41.69:9292         |
+-----------+----------------------------------+
+-----------+----------------------------------+
| neutron   | Value                            |
+-----------+----------------------------------+
| id        | 046022a9a5414ebf9546019b633410ae |
| interface | admin                            |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:9696        |
+-----------+----------------------------------+
+-----------+----------------------------------+
| neutron   | Value                            |
+-----------+----------------------------------+
| id        | a2d9a451849f4170b06d2cefbcf645d7 |
| interface | internal                         |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:9696        |
+-----------+----------------------------------+
+-----------+----------------------------------+
| neutron   | Value                            |
+-----------+----------------------------------+
| id        | ea79b35676dc4939a42b5f3f35e35a56 |
| interface | public                           |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:9696        |
+-----------+----------------------------------+
+-----------+----------------------------------+
| keystone  | Value                            |
+-----------+----------------------------------+
| id        | 1acf4ac6efcf4cb0beb2a4a96f32dacd |
| interface | internal                         |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:5000/v2.0   |
+-----------+----------------------------------+
+-----------+----------------------------------+
| keystone  | Value                            |
+-----------+----------------------------------+
| id        | 613fd95a43e64b4aac1e5434bfd7ee52 |
| interface | admin                            |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:35357/v2.0  |
+-----------+----------------------------------+
+-----------+----------------------------------+
| keystone  | Value                            |
+-----------+----------------------------------+
| id        | 7d1182aefdb8446db5b7bcfed6ac1e2e |
| interface | public                           |
| region    | RegionOne                        |
| region_id | RegionOne                        |
| url       | http://10.119.47.106:5000/v2.0   |
+-----------+----------------------------------+
```
```
nova image-list
+--------------------------------------+---------------------+--------+--------+
| ID                                   | Name                | Status | Server |
+--------------------------------------+---------------------+--------+--------+
| 7d05df9f-1435-4aea-ab97-5e6e5aec3be8 | busybox             | ACTIVE |        |
| ecee5308-40c0-4a1b-b2c6-647696ae5145 | cirros-0.3.4-x86_64 | ACTIVE |        |
| ee2fea6e-1c00-42e1-ae5f-c91b944bea06 | nginx               | ACTIVE |        |
+--------------------------------------+---------------------+--------+--------+
```
