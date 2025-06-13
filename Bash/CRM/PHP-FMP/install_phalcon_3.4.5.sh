#!/bin/bash

set -e

PHALCON_VERSION="3.4.5"
PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null)

echo "[1/5] Installing dependencies..."
apt update
apt install -y php${PHP_VER}-dev gcc make re2c libpcre3-dev git unzip php-xml

echo "[2/5] Cloning Phalcon ${PHALCON_VERSION}..."
rm -rf cphalcon
git clone -b v${PHALCON_VERSION} --depth=1 https://github.com/phalcon/cphalcon.git

echo "[3/5] Building Phalcon extension..."
cd cphalcon/build
./install

echo "[4/5] Enabling extension..."
EXT_FILE="/etc/php/${PHP_VER}/mods-available/phalcon.ini"
echo "extension=phalcon.so" > "$EXT_FILE"

ln -sf "$EXT_FILE" "/etc/php/${PHP_VER}/cli/conf.d/30-phalcon.ini"
if [[ -d "/etc/php/${PHP_VER}/fpm/conf.d" ]]; then
  ln -sf "$EXT_FILE" "/etc/php/${PHP_VER}/fpm/conf.d/30-phalcon.ini"
  systemctl restart php${PHP_VER}-fpm
fi

echo "[5/5] Verifying installation..."
php -m | grep -i phalcon && echo "✅ Phalcon ${PHALCON_VERSION} installed successfully!" || echo "❌ Installation failed!"
