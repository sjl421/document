FROM python:2.7
ENV PYTHONUNBUFFERED 1
ENV http_proxy http://xwx340236:2016.huawei@proxy.huawei.com:8080/
WORKDIR /usr/share/nginx/html
ADD . /usr/share/nginx/html
RUN pip install -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com -r requirements.txt
ADD ./uwsgi.ini /usr/share/nginx/html/uwsgi.ini
