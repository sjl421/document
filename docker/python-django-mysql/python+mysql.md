# APP + Python + MySQL #
## 1.Dockerfile ##
```
FROM python:2.7
ENV PYTHONUNBUFFERED 1
ENV http_proxy http://xwx340236:2016.huawei@proxy.huawei.com:8080/
WORKDIR /usr/share/nginx/html
ADD . /usr/share/nginx/html
RUN pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com -r requirements.txt
ADD ./uwsgi.ini /usr/share/nginx/html/uwsgi.ini
```
## 2.docker-compose.yml ##
```
version: '2'
services:
  db:
    image: docker.io/mysql:latest
    restart: always
    volumes:
      - ./dbdir:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: operation
      MYSQL_USER: operation
      MYSQL_PASSWORD: operation
  http:
    image: docker.io/nginx:latest
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/nginx.conf
      - .:/usr/share/nginx/html
    ports:
      - "9090:9090"
    depends_on:
      - app
    links:
      - app
  app:
    build: .
    volumes:
      - .:/usr/share/nginx/html
    command: "uwsgi --ini /usr/share/nginx/html/uwsgi.ini"
    depends_on:
      - db
    links:
      - db
```
## 3.nginx ##
```
# the upstream component nginx needs to connect to
upstream django {
    server app:9000; # for a web port socket (we'll use this first)
}

# configuration of the server
server {
    # the port your site will be served on
    listen      9090;
    # the domain name it will serve for
    server_name .example.com; # substitute your machine's IP address or FQDN
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    # Django media
    location /media  {
        alias /path/to/your/mysite/media;  # your Django project's media files - amend as required
    }

    location /static {
        alias /usr/share/nginx/html/operation/admin/static; # your Django project's static files - amend as required
    }

    # Finally, send all non-media requests to the Django server.
    location / {
        uwsgi_pass  django;
        include     /etc/nginx/uwsgi_params; # the uwsgi_params file you installed
    }
}
```
## 4.requirements.txt ##
```
Django
MySQL-python
uwsgi
```
## 5.uwsgi.ini ##
```
[uwsgi]
# Django-related settings
socket 		= 0.0.0.0:9000
# the base directory (full path)
chdir           = /usr/share/nginx/html/operation
# Django's wsgi file
module          = operation.wsgi:application

# process-related settings
# master
master          = true
# maximum number of worker processes
processes       = 10
vacuum          = true
```

~~pidfile = /var/run/uwsgi.pid~~  
~~daemonize = /var/log/uwsgi.log~~
> pidfile和daemonize意味着容器运行后台，在容器中不需要，不然当容器启动后容器会处于Exited状态

## 6.start ##
```
docker-compose up -d --build
```
## 7.logs ##
```
[uWSGI] getting INI configuration from /usr/share/nginx/html/uwsgi.ini
*** Starting uWSGI 2.0.13.1 (64bit) on [Fri Sep  2 07:57:36 2016] ***
compiled with version: 4.9.2 on 02 September 2016 07:57:07
os: Linux-3.10.0-327.18.2.el7.x86_64 #1 SMP Thu May 12 11:03:55 UTC 2016
nodename: 3efe34d40fb4
machine: x86_64
clock source: unix
pcre jit disabled
detected number of CPU cores: 4
current working directory: /usr/share/nginx/html
detected binary path: /usr/local/bin/uwsgi
uWSGI running as root, you can use --uid/--gid/--chroot options
*** WARNING: you are running uWSGI as root !!! (use the --uid flag) ***
chdir() to /usr/share/nginx/html/operation
your processes number limit is 1048576
your memory page size is 4096 bytes
detected max file descriptor number: 1048576
lock engine: pthread robust mutexes
thunder lock: disabled (you can enable it with --thunder-lock)
uwsgi socket 0 bound to TCP address 0.0.0.0:9000 fd 3
Python version: 2.7.12 (default, Aug 26 2016, 20:43:47)  [GCC 4.9.2]
*** Python threads support is disabled. You can enable it with --enable-threads ***
Python main interpreter initialized at 0x143d620
your server socket listen backlog is limited to 100 connections
your mercy for graceful operations on workers is 60 seconds
mapped 800448 bytes (781 KB) for 10 cores
*** Operational MODE: preforking ***
WSGI app 0 (mountpoint='') ready in 0 seconds on interpreter 0x143d620 pid: 1 (default app)
*** uWSGI is running in multiple interpreter mode ***
spawned uWSGI master process (pid: 1)
spawned uWSGI worker 1 (pid: 10, cores: 1)
spawned uWSGI worker 2 (pid: 11, cores: 1)
spawned uWSGI worker 3 (pid: 12, cores: 1)
spawned uWSGI worker 4 (pid: 13, cores: 1)
spawned uWSGI worker 5 (pid: 14, cores: 1)
spawned uWSGI worker 6 (pid: 15, cores: 1)
spawned uWSGI worker 7 (pid: 16, cores: 1)
spawned uWSGI worker 8 (pid: 17, cores: 1)
spawned uWSGI worker 9 (pid: 18, cores: 1)
spawned uWSGI worker 10 (pid: 19, cores: 1)
```
