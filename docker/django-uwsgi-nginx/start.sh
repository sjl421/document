#! /bin/bash
uwsgi --ini /etc/uwsgi.ini &
nginx -g 'daemon off;'
