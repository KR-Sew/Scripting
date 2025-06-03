cd /srv/myapp
docker build -t php-fpm-phalcon ./php

docker run -d --name php-fpm \
  -v /srv/myapp/src:/var/www/html \
  -p 9000:9000 \
  php-fpm-phalcon
