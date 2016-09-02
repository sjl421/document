# Docker Compose redmine MySQL #
## 1.Pull redmine image ##
```
docker pull redmine
```
## 2.Create yaml file ##
```
vi docker-compose.yml
version: '2'
services:
  db:
    image: docker.io/mysql:latest
    volumes:
      - "./dbdir:/var/lib/mysql"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: redmine
      MYSQL_USER: redmine
      MYSQL_PASSWORD: redmine
      MYSQL_ENV_MYSQL_USER: redmine
      MYSQL_ENV_MYSQL_PASSWORD: redmine
      MYSQL_ENV_MYSQL_DATABASE: redmine
  redmine:
    image: docker.io/redmine:latest
    environment:
      MYSQL_PORT_3306_TCP: 3306
      REDMINE_DB_MYSQL: db
      MYSQL_ENV_MYSQL_USER: redmine
      MYSQL_ENV_MYSQL_PASSWORD: redmine
      MYSQL_ENV_MYSQL_DATABASE: redmine
    volumes:
      - "./datadir:/usr/src/redmine/files"
    ports:
      - "3000:3000"
    depends_on:
      - db
    links:
      - db
```
## 3.Start容器 ##
```
docker-compose up -d
```
## 4.查看log ##
```
docker logs -f CONTAINER_ID
```
```
[2016-09-02 01:55:54] INFO  WEBrick 1.3.1
[2016-09-02 01:55:54] INFO  ruby 2.2.5 (2016-04-26) [x86_64-linux]
[2016-09-02 01:55:54] INFO  WEBrick::HTTPServer#start: pid=1 port=3000
```
