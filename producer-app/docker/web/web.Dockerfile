FROM nginx

ARG WORK_DIR=/var/www/html
ARG HOST_IP
ARG ROOT_DIR=/app/public
ENV HOST_IP=${HOST_IP}

WORKDIR $WORK_DIR
RUN rm /etc/nginx/conf.d/default.conf
COPY ./docker/web/conf.d/app.conf /etc/nginx/conf.d/app.conf
COPY ./docker/web/index.php /var/www/html/public/index.php
COPY ./docker/web/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV CLIENT_MAX_BODY_SIZE=1m \
    NGINX_PORT=80 \
    NGINX_HOST=_ \
    STATIC_FILES_ROOT=$ROOT_DIR \
    FASTCGI_FILES_ROOT=/app \
    HOST_IP=${HOST_IP} \
    FASTCGI_HOST=$HOST_IP \
    FASTCGI_PORT=9004 \
    FASTCGI_CONNECT_TIMEOUT=60 \
    FASTCGI_SEND_TIMEOUT=60 \
    FASTCGI_READ_TIMEOUT=60 \
    PHP_VALUE="" \
    TZ=Asia/Dhaka 
    
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]