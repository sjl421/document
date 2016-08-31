FROM docker.io/centos:centos6.6
MAINTAINER bq.xiao <xiaobaoqiang@163.com>

# workdir
WORKDIR /root/

# set proxy
ENV http_proxy http://xwx340236:2016.huawei@proxy.huawei.com:8080/

# set nginx repo
COPY ./nginx.repo /etc/yum.repos.d/nginx.repo

# update system
#RUN yum -y update

# install tools
RUN yum -y groupinstall "Development Tools" && yum -y install tar zlib-devel bzip2-devel pcre-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel nginx mysql-devel

# download Python2.7 source
#RUN curl -o /root/Python-2.7.12.tgz -x $http_proxy https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz -k
COPY ./Python-2.7.12.tgz /root/Python-2.7.12.tgz

# install python2.7
RUN cd /root/ && tar -zxf Python-2.7.12.tgz
RUN cd Python-2.7.12 && ./configure && make && make install

# fix path
ENV PATH /usr/local/bin:$PATH

# print python version
RUN python2.7 -V

# install pip
COPY ./get-pip.py /root/get-pip.py
RUN python2.7 /root/get-pip.py --proxy="$http_proxy" -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com
RUN pip -V

# update pip
RUN pip2.7 install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com pip -U

# install django
RUN pip2.7 install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com django -U

# install uwsgi
RUN pip2.7 install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com uwsgi -U

# install mysql connector
RUN pip2.7 install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com MySQL-python -U

# config nginx
COPY ./nginx.conf /etc/nginx/conf.d/

# config uwsgi
COPY ./uwsgi.ini /etc/uwsgi.ini

# copy app
#COPY ./operation.tar.gz /root/
#RUN cd /root/ && tar -zxf operation.tar.gz

# start command
COPY ./start.sh /root/
RUN chmod 755 /root/start.sh
CMD ["/root/start.sh"]

# expose port
EXPOSE 8080
