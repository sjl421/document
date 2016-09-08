# Openstack(kilo)+Docker 安装指导 #
## 1.安装Identity service ##
Identity service安装在Controller Node上
### 1.安装过程 ###
#### 1.创建数据库 ####
```
mysql -u root -p
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
  IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
  IDENTIFIED BY 'openstack';
```
#### 2.生成随机Token ####
```
openssl rand -hex 10
```
#### 3.安装package ####
```
yum install openstack-keystone httpd mod_wsgi python-openstackclient memcached python-memcached
```
#### 4.配置keystone ####
```
vi /etc/keystone/keystone.conf
[DEFAULT]
admin_token = c84685457f8a0b2a5f08
verbose = True

[database]
connection = mysql://keystone:openstack@10.119.47.106/keystone

[memcache]
servers = localhost:11211

[token]
provider = keystone.token.providers.uuid.Provider
driver = keystone.token.persistence.backends.memcache.Token

[revoke]
driver = keystone.contrib.revoke.backends.sql.Revoke
```
#### 5.初始化keystone ####
```
su -s /bin/sh -c "keystone-manage db_sync" keystone
```
#### 6.配置Apache HTTP Server ####
```
vi /etc/httpd/conf/httpd.conf
ServerName SIA1000065975
```
```
vi /etc/httpd/conf.d/wsgi-keystone.conf
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /var/www/cgi-bin/keystone/main
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    LogLevel info
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /var/www/cgi-bin/keystone/admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    LogLevel info
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined
</VirtualHost>
```
```
mkdir -p /var/www/cgi-bin/keystone
```
**错误的URL**

~~curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin~~

**正确的URL**

>curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/liberty | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin

```
chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*
```
#### 7.开机自启动 ####
```
systemctl enable memcached.service
systemctl start memcached.service
systemctl enable httpd.service
systemctl start httpd.service
```
### 2.Create the service entity and API endpoint ###
#### 1.设置环境变量 ####
```
export OS_TOKEN=c84685457f8a0b2a5f08
export OS_URL=http://10.119.47.106:35357/v2.0
```
#### 2.创建API ####
```
openstack service create --name keystone --description "OpenStack Identity" identity
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Identity               |
| enabled     | True                             |
| id          | eeda8de210ba4804992b97b34831b5a5 |
| name        | keystone                         |
| type        | identity                         |
+-------------+----------------------------------+
```
```
openstack endpoint create \
--publicurl http://10.119.41.69:5000/v2.0 \
--internalurl http://10.119.41.69:5000/v2.0 \
--adminurl http://10.119.41.69:35357/v2.0 \
--region RegionOne \
identity
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| adminurl     | http://10.119.47.106:35357/v2.0  |
| enabled      | True                             |
| id           | 96eab7a20851409d8c69f56f2db0a947 |
| internalurl  | http://10.119.47.106:5000/v2.0   |
| publicurl    | http://10.119.47.106:5000/v2.0   |
| region       | RegionOne                        |
| service_id   | eeda8de210ba4804992b97b34831b5a5 |
| service_name | keystone                         |
| service_type | identity                         |
+--------------+----------------------------------+
```
### 3.Create projects, users, and roles ###
#### 1.Create an administrative project ####
```
openstack project create --description "Admin Project" admin
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Admin Project                    |
| enabled     | True                             |
| id          | 1a9c9f23900b41389bf8ab06f09df680 |
| name        | admin                            |
+-------------+----------------------------------+
```
```
openstack user create --password-prompt admin
+----------+----------------------------------+
| Field    | Value                            |
+----------+----------------------------------+
| email    | None                             |
| enabled  | True                             |
| id       | fcfc3c5e1d02424aa697be66f1651837 |
| name     | admin                            |
| username | admin                            |
+----------+----------------------------------+
```
```
openstack role create admin
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | 6a2fa7c1f4644143a35339a53fde842d |
| name  | admin                            |
+-------+----------------------------------+
```
```
openstack role add --project admin --user admin admin
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | 6a2fa7c1f4644143a35339a53fde842d |
| name  | admin                            |
+-------+----------------------------------+
```
#### 2.Create service ####
```
openstack project create --description "Service Project" service
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Service Project                  |
| enabled     | True                             |
| id          | 544d7bb04cdf45cb985de2548ecc38d5 |
| name        | service                          |
+-------------+----------------------------------+
```
#### 3.Create the demo project ####
```
openstack project create --description "Demo Project" demo
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Demo Project                     |
| enabled     | True                             |
| id          | cf52c990f6294ba4a5a3c8d657f9b197 |
| name        | demo                             |
+-------------+----------------------------------+
```
```
openstack user create --password-prompt demo
+----------+----------------------------------+
| Field    | Value                            |
+----------+----------------------------------+
| email    | None                             |
| enabled  | True                             |
| id       | 753b4366c418490d8fb76d67d30778ef |
| name     | demo                             |
| username | demo                             |
+----------+----------------------------------+
```
```
openstack role create user
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | a319b8fadb664d268a464a99cef0dc5e |
| name  | user                             |
+-------+----------------------------------+
```
```
openstack role add --project demo --user demo user
+-------+----------------------------------+
| Field | Value                            |
+-------+----------------------------------+
| id    | a319b8fadb664d268a464a99cef0dc5e |
| name  | user                             |
+-------+----------------------------------+
```
### 4.验证 ###
>Edit the /usr/share/keystone/keystone-dist-paste.ini file and remove admin_token_auth from the [pipeline:public_api], [pipeline:admin_api], and [pipeline:api_v3] sections.

```
unset OS_TOKEN OS_URL
```
```
openstack --os-auth-url http://10.119.41.69:35357 \
  --os-project-name admin --os-username admin --os-auth-type password \
  token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2016-09-08T03:44:05.451663Z      |
| id         | 968b04e2ecc84df1b733fa770db9157a |
| project_id | 1a9c9f23900b41389bf8ab06f09df680 |
| user_id    | fcfc3c5e1d02424aa697be66f1651837 |
+------------+----------------------------------+
```
```
openstack --os-auth-url http://controller:35357 \
  --os-project-domain-id default --os-user-domain-id default \
  --os-project-name admin --os-username admin --os-auth-type password \
  token issue
+------------+----------------------------------+
| Field      | Value                            |
+------------+----------------------------------+
| expires    | 2016-09-08T03:44:05.451663Z      |
| id         | 968b04e2ecc84df1b733fa770db9157a |
| project_id | 1a9c9f23900b41389bf8ab06f09df680 |
| user_id    | fcfc3c5e1d02424aa697be66f1651837 |
+------------+----------------------------------+
```
```
openstack --os-auth-url http://controller:35357 \
  --os-project-name admin --os-username admin --os-auth-type password \
  project list
+----------------------------------+---------+
| ID                               | Name    |
+----------------------------------+---------+
| 1a9c9f23900b41389bf8ab06f09df680 | admin   |
| 544d7bb04cdf45cb985de2548ecc38d5 | service |
| cf52c990f6294ba4a5a3c8d657f9b197 | demo    |
+----------------------------------+---------+
```
```
openstack --os-auth-url http://controller:35357 \
  --os-project-name admin --os-username admin --os-auth-type password \
  user list
+----------------------------------+---------+
| ID                               | Name    |
+----------------------------------+---------+
| 6f62c9630ae2492eaaef001e5e3244bd | nova    |
| 753b4366c418490d8fb76d67d30778ef | demo    |
| c3d3fb5506384af1bc2b2e21d323a768 | glance  |
| e4c6b5d3420f42abb987f774496098a4 | neutron |
| fcfc3c5e1d02424aa697be66f1651837 | admin   |
+----------------------------------+---------+
```
### 4.创建environment scripts ###
```
vi admin-openrc.sh
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://10.119.47.106:35357/v3
export OS_IMAGE_API_VERSION=2
```
```
vi demo-openrc.sh
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=demo
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://10.119.47.106:5000/v3
export OS_IMAGE_API_VERSION=2
```
