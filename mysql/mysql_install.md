## MySQL安装简明教程
### 1.添加mysql repo
mysql官网下载repo文件https://dev.mysql.com/downloads/repo/yum/

    wget https://repo.mysql.com//mysql57-community-release-el7-9.noarch.rpm
    rpm ivh mysql57-community-release-el7-9.noarch.rpm
    
### 2.yum安装mysql server
    yum install -y mysql-community-server.x86_64
    
### 3.获取root密码
方法一：默认空密码，尝试空密码登陆mysql，如果能够登陆则修改root密码

    # mysql -u root -p
    Enter password:
    ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
    
方法二：从mysql的log文件中获取初始随机密码

打开/var/log/mysqld.log文件，搜索字符串A temporary password is generated for root@localhost:，
可以找到这个随机密码，通常这一行日志在log文件的最初几行，比较容易看到
### 4.修改root密码
    mysql> use mysql; 
    mysql> update user set password=password('123') where user='root';
    mysql> flush privileges;
