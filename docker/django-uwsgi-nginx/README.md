# 构建容器方法 #
```
docker build -t app:v1 .
```
# 启动容器方法 #
```
docker run -d -p 9090:8080 -v /data/images/operation/operation:/usr/share/nginx/html/operation:rw app:v1
```
