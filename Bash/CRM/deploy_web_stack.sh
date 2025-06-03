#!/bin/bash

set -e

APP_DOMAIN="example.com"
APP_ROOT="/var/www/myapp/public"
DB_NAME="myappdb"
DB_USER="myuser"
DB_PASS="StrongP@ssword"
REDIS_PASS="StrongRedisP@ss"
PHP_VER="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || echo '8.1')"

echo "[1/9] Installing packages..."
apt update
apt install -y nginx php-fpm php-pgsql php-cli php-curl php-xml php-mbstring php-bcmath php-opcache php-redis postgresql redis-server ufw fail2ban certbot python3-certbot-nginx

echo "[2/9] Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
EOF
sed -i "s/^#*listen_addresses = .*/listen_addresses = 'localhost'/" /etc/postgresql/*/main/postgresql.conf
sed -i "s/^local\s\+all\s\+all\s\+.*/local   all             all                                     md5/" /etc/postgresql/*/main/pg_hba.conf

systemctl restart postgresql

echo "[3/9] Securing Redis..."
sed -i "s/^# *requirepass .*$/requirepass $REDIS_PASS/" /etc/redis/redis.conf
sed -i "s/^bind .*/bind 127.0.0.1 ::1/" /etc/redis/redis.conf
sed -i "s/^# *protected-mode yes/protected-mode yes/" /etc/redis/redis.conf

systemctl restart redis-server

echo "[4/9] Hardening PHP..."
PHP_INI="/etc/php/$PHP_VER/fpm/php.ini"
sed -i "s/^expose_php = On/expose_php = Off/" $PHP_INI
sed -i "s/^display_errors = On/display_errors = Off/" $PHP_INI
sed -i "s/^;*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/" $PHP_INI
sed -i "s/^;*session.cookie_httponly =.*/session.cookie_httponly = 1/" $PHP_INI
sed -i "s/^;*session.cookie_secure =.*/session.cookie_secure = 1/" $PHP_INI
echo "session.save_handler = redis" >> $PHP_INI
echo "session.save_path = \"tcp://:$REDIS_PASS@127.0.0.1:6379\"" >> $PHP_INI

systemctl restart php$PHP_VER-fpm

echo "[5/9] Creating app root..."
mkdir -p "$APP_ROOT"
chown -R www-data:www-data "$(dirname "$APP_ROOT")"
echo "<?php phpinfo(); ?>" > "$APP_ROOT/index.php"

echo "[6/9] Setting up NGINX site..."
cat > /etc/nginx/sites-available/myapp.conf <<EOF
server {
    listen 80;
    server_name $APP_DOMAIN;

    root $APP_ROOT;
    index index.php index.html;

    access_log /var/log/nginx/myapp.access.log;
    error_log /var/log/nginx/myapp.error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
}
EOF

ln -sf /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

echo "[7/9] Configuring UFW firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "[8/9] Enabling HTTPS with Let's Encrypt..."
certbot --non-interactive --agree-tos --redirect --nginx -d "$APP_DOMAIN" -m admin@"$APP_DOMAIN"

echo "[9/9] Enabling automatic security updates..."
apt install -y unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades

echo "✅ Deployment complete for $APP_DOMAIN"
