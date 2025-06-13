FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql zip

RUN pecl install redis && docker-php-ext-enable redis

COPY ./php.ini /usr/local/etc/php/php.ini
