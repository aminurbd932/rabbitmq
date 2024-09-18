FROM php:8.3.0-fpm

ARG HOST_APP_ROOT_DIR=./codes
ARG WORK_DIR=/var/www/html/

ENV TZ=Asia/Dhaka

WORKDIR $WORK_DIR

RUN apt-get update
RUN apt-get install -y \
    libpng-dev \
    zlib1g-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    curl \
    unzip

RUN docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install zip && \
    docker-php-ext-install opcache && \
    docker-php-ext-install bcmath && \
    docker-php-source delete

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN groupadd -g 1000 app && \
    useradd -u 1000 -ms /bin/bash -g app app

COPY $HOST_APP_ROOT_DIR/storage ./storage
COPY $HOST_APP_ROOT_DIR/bootstrap ./bootstrap
RUN chmod -R 777 ./storage
RUN chmod -R 777 ./bootstrap

RUN chown -R app:app $WORK_DIR

USER app

COPY --chown=app:app $HOST_APP_ROOT_DIR/composer.json $WORK_DIR
COPY --chown=app:app $HOST_APP_ROOT_DIR/composer.lock $WORK_DIR
COPY --chown=app:app ./docker/app/php.ini /usr/local/etc/php/php.ini

RUN composer install --no-interaction --no-scripts --no-autoloader

COPY --chown=app:app $HOST_APP_ROOT_DIR/app ./app
COPY --chown=app:app $HOST_APP_ROOT_DIR/config ./config
COPY --chown=app:app $HOST_APP_ROOT_DIR/database ./database
COPY --chown=app:app $HOST_APP_ROOT_DIR/public ./public
COPY --chown=app:app $HOST_APP_ROOT_DIR/resources ./resources
COPY --chown=app:app $HOST_APP_ROOT_DIR/routes ./routes
#COPY --chown=app:app $HOST_APP_ROOT_DIR/lang ./lang
COPY --chown=app:app $HOST_APP_ROOT_DIR/.env ./.env
COPY --chown=app:app $HOST_APP_ROOT_DIR/artisan ./artisan

RUN composer install --no-dev --optimize-autoloader --classmap-authoritative

# RUN php artisan cache:clear && \
#     php artisan config:clear && \
#     php artisan config:cache

RUN composer require predis/predis
RUN composer require php-amqplib/php-amqplib

EXPOSE 9005

CMD ["php-fpm"]
