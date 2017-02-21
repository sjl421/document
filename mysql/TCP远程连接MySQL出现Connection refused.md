```
1.问题

TCP远程连接MySQL出现Connection refused
2.问题排查

1.确认客户的网络是否联通，经确认客户端的网络是正常的
2.确认服务器的网络是否正常，确认服务器的网络是正常的
3.关闭服务器的防护墙
systemctl stop firewalld.service
问题依然再现，问题没解决。
4.重启MySQL
systemctl restart mysqld.service
问题依然再现，问题没解决。
5.确认3306端口是否开启
[root@SIA1000094076 ~]# netstat -natpl | grep mysqld
tcp6        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      53827/mysqld
发现问题1：MySQL新版本默认监听在IPv6的地址族上。
更改为监听IPv4地址族，修改 my.cnf 添加一行配置：
vi /etc/my.cnf
bind-address = 0.0.0.0
重启MySQL
systemctl restart mysqld.service
问题依然再现，问题没解决。
mysql -u root -p
mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select user, host from user;
+-----------+-----------+
| user      | host      |
+-----------+-----------+
| root      | localhost |
| mysql.sys | localhost |
+-----------+-----------+
2 rows in set (0.01 sec)
发现问题2：MySQL只允许localhost的主机连接。
修改host的值
update user set host = '%' where user = 'root'
刷新MySQL的权限
flush privileges;
确认修改：
mysql> select user, host from user;
+-----------+-----------+
| user      | host      |
+-----------+-----------+
| root      | %         |
| mysql.sys | localhost |
+-----------+-----------+
2 rows in set (0.01 sec)
至此，问题解决，远程连接MySQL成功。
```
