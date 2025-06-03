FROM php:7.4-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip gcc make re2c \
    libpcre3-dev php-xml \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql

# Install Phalcon 3.4.5
RUN git clone -b v3.4.5 --depth=1 https://github.com/phalcon/cphalcon.git /usr/src/cphalcon \
    && cd /usr/src/cphalcon/build \
    && ./install \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/30-phalcon.ini \
    && rm -rf /usr/src/cphalcon

# Set working directory
WORKDIR /var/www/html

# Copy project files (optional)
COPY ./src/ /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Health check (optional)
HEALTHCHECK CMD curl -f http://localhost || exit 1
