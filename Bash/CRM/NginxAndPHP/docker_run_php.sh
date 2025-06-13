docker run -d --name php-fpm \
  -v $(pwd)/src:/var/www/html \
  -p 9000:9000 \
  phalcon-php-fpm
