#!/bin/bash

set -e

# Variables
NGINX_INSTALL_DIR="/usr/local/nginx"
NGINX_BIN_PATH="$NGINX_INSTALL_DIR/sbin/nginx"
SYSTEM_NGINX_BIN="/usr/sbin/nginx"
NGINX_DOWNLOAD_PAGE="https://nginx.org/en/download.html"

# Get current installed version (if exists)
if command -v nginx >/dev/null 2>&1; then
    NGINX_CURRENT_VERSION=$(nginx -v 2>&1 | awk -F/ '{print $2}')
else
    NGINX_CURRENT_VERSION="none"
fi

# Fetch latest stable version
LATEST_VERSION=$(curl -s "$NGINX_DOWNLOAD_PAGE" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | head -1)
TARBALL="nginx-$LATEST_VERSION.tar.gz"
DOWNLOAD_URL="https://nginx.org/download/$TARBALL"

# Function to install dependencies
install_dependencies() {
    echo "Installing build dependencies..."
    sudo apt update
    sudo apt install -y build-essential libpcre2-dev libssl-dev zlib1g-dev curl
}

# Function to download and build NGINX
build_nginx() {
    echo "Downloading $TARBALL..."
    curl -fLO "$DOWNLOAD_URL"

    echo "Extracting..."
    tar -xzf "$TARBALL"
    cd "nginx-$LATEST_VERSION" || exit 1

    echo "Configuring and compiling..."
    ./configure --prefix="$NGINX_INSTALL_DIR" --with-http_ssl_module --with-pcre
    make
    sudo make install

    cd ..
    rm -rf "nginx-$LATEST_VERSION" "$TARBALL"
}

# Function to install system-wide binary and service
install_system_binary_and_service() {
    echo "Installing NGINX binary system-wide..."

    if [ -f "$SYSTEM_NGINX_BIN" ]; then
        echo "Backing up existing /usr/sbin/nginx to /usr/sbin/nginx.bak"
        sudo mv "$SYSTEM_NGINX_BIN" "/usr/sbin/nginx.bak.$(date +%s)"
    fi

    sudo ln -sf "$NGINX_BIN_PATH" "$SYSTEM_NGINX_BIN"

    echo "Creating systemd service for NGINX if missing..."
    SERVICE_FILE="/etc/systemd/system/nginx.service"
    if [ ! -f "$SERVICE_FILE" ]; then
        sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=NGINX from source
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PrivateTmp=true
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
    fi

    echo "Enabling and starting NGINX..."
    sudo systemctl enable nginx
    sudo systemctl restart nginx
}

# Main logic
echo "Installed version: $NGINX_CURRENT_VERSION"
echo "Latest version:    $LATEST_VERSION"

if [ "$NGINX_CURRENT_VERSION" = "none" ]; then
    echo "NGINX is not installed. Installing..."
    install_dependencies
    build_nginx
    install_system_binary_and_service
elif [ "$NGINX_CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating NGINX from $NGINX_CURRENT_VERSION to $LATEST_VERSION..."
    install_dependencies
    build_nginx
    install_system_binary_and_service
else
    echo "NGINX is already up to date."
fi
