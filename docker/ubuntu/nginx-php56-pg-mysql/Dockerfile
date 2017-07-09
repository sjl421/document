FROM ubuntu:latest

# contact 
MAINTAINER bq-xiao <xbaoqiang@gmail.com>

# set environment parameters
ENV POSTGRESQL_VERSION 9.3
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_BUILD_DEPS libpq-dev libmysqlclient18 libmysqlclient-dev libmysqld-dev libpng-dev libcurl4-openssl-dev libpcre3-dev libreadline6-dev librecode-dev libsqlite3-dev libssl-dev libxml2-dev xz-utils libmcrypt-dev autoconf file g++ gcc libc-dev make pkg-config re2c ca-certificates curl libpcre3 librecode0 libsqlite3-0 libxml2  
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-mbstring --with-mcrypt --with-mysql --with-mysqli --with-pdo-mysql --with-pdo-pgsql --with-pgsql --with-pdo-sqlite --enable-soap --with-libxml-dir --enable-sockets --enable-zip --enable-mysqlnd --with-gd --enable-maintainer-zts
ENV PHP_VERSION 5.6.13
ENV GPG_KEYS 0BD78B5F97500D450838F95DFE857D9A90D90EC1 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3

# install curl
RUN apt-get update && apt-get install -y curl xz-utils wget --no-install-recommends

# postgresql library
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && wget --no-check-certificate https://www.postgresql.org/media/keys/ACCC4CF8.asc && gpg --import ACCC4CF8.asc && rm -f ACCC4CF8.asc  
 
# mysql library
RUN wget "http://repo.mysql.com/mysql-apt-config_0.3.7-1ubuntu14.04_all.deb" && dpkg -i mysql-apt-config_0.3.7-1ubuntu14.04_all.deb && rm -f mysql-apt-config_0.3.7-1ubuntu14.04_all.deb

# install nginx
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list

# set configure path
RUN mkdir -p $PHP_INI_DIR/conf.d

# import keys
RUN set -xe \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

# download php 5.6
RUN curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror" -o php.tar.xz \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.xz.asc/from/this/mirror" -o php.tar.xz.asc \
	&& gpg --verify php.tar.xz.asc \
	&& mkdir -p /usr/src/php \
	&& tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
	&& rm php.tar.xz*

RUN set -x apt-get update && apt-get install -y $PHP_EXTRA_BUILD_DEPS nginx --no-install-recommends

RUN cd /usr/src/php && ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--enable-cgi \
		--enable-mysqlnd \
		--with-curl \
		--with-openssl \
		--with-pcre \
		--with-readline \
		--with-recode \
		--with-zlib \
	&& make && make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& make clean

# clean cache
RUN apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -f /etc/apt/sources.list.d/*.list

# add log dir and copy conf files to right dir
RUN mkdir /var/log/php-fpm
COPY php-fpm.conf /usr/local/etc/
COPY www.conf /usr/local/etc/php/conf.d/

# add volume
VOLUME ["/var/cache/nginx"]

# copy shell to bin path
COPY start /usr/local/sbin/
RUN chmod 755 /usr/local/sbin/start

# open port
EXPOSE 9000 80 443
# end

