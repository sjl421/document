FROM centos:latest
MAINTAINER bq-xiao <xbaoqiang@gmail.com>

# clear apache and old php
RUN yum remove php* httpd*

# install nginx and php 
RUN rpm -ivh ftp://mirror.switch.ch/pool/4/mirror/centos/7.1.1503/extras/x86_64/Packages/epel-release-7-5.noarch.rpm && rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm && rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm 
RUN yum --enablerepo=remi,remi-php56 install -y nginx php56-php-cli php56-php-common php56-php-fpm php56-php-gd php56-php-mbstring php56-php-mcrypt php56-php-mysqlnd php56-php-opcache php56-php-pdo php56-php-pear php56-php-pgsql php56-php-process php56-php-xml php56-runtime

# clean
RUN yum clean all && rm -f /etc/yum.repos.d/*.repo

# systemd enable
RUN systemctl enable php56-php-fpm.service && systemctl enable nginx.service

EXPOSE 9000 80
# end
