# Docker Compose and Django #
## 1.安装Compose ##
```
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose -k
chmod +x /usr/local/bin/docker-compose
```
## 2.验证Compose ##
```
$ docker-compose --version
docker-compose version: 1.8.0
```
## 3.创建Dockerfile ##
```
FROM python:2.7
ENV PYTHONUNBUFFERED 1
ENV http_proxy http://xwx340236:2016.huawei@proxy.huawei.com:8080/
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com -U -r requirements.txt
ADD . /code/
```
## 4.requirements.txt ##
```
pip
Django
MySQL-python
```
## 5.docker-compose.yml ##
```
version: '2'
services:
  db:
    image: docker.io/mysql:latest
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: composeexample
      MYSQL_USER: composeexample
      MYSQL_PASSWORD: 123456
  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/code
    ports:
      - "8000:8000"
    depends_on:
      - db
    links:
      - db
```
## 6.Create a Django project ##
```
docker-compose run web django-admin.py startproject composeexample .
```
## 7.改变目录权限 ##
```
sudo chown -R $USER:$USER .
```
## 8.连接MySQL ##
```
vi settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'composeexample',
        'USER': 'root',
        'PASSWORD': 'root',
        'HOST': 'db',
        'PORT': '3306',
    }
}
```
## 9.启动容器 ##
```
docker-compose up
```
```
web_1  | You have 13 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
web_1  | Run 'python manage.py migrate' to apply them.
web_1  | September 01, 2016 - 05:49:16
web_1  | Django version 1.10, using settings 'composeexample.settings'
web_1  | Starting development server at http://0.0.0.0:8000/
web_1  | Quit the server with CONTROL-C.
```
