#!/bin/sh
set -e

envsubst '${NGINX_PORT} ${NGINX_HOST} ${FASTCGI_HOST} ${FASTCGI_PORT} ${FASTCGI_CONNECT_TIMEOUT} ${FASTCGI_SEND_TIMEOUT} ${FASTCGI_READ_TIMEOUT}' < /etc/nginx/conf.d/app.conf > /etc/nginx/conf.d/app.conf.tmp
mv /etc/nginx/conf.d/app.conf.tmp /etc/nginx/conf.d/app.conf

exec "$@"
