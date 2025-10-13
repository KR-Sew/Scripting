#!/usr/bin/env bash
set -euo pipefail

# === Variables ===
NGINX_INSTALL_DIR="/usr/local/nginx"
NGINX_BIN_PATH="$NGINX_INSTALL_DIR/sbin/nginx"
SYSTEM_NGINX_BIN="/usr/sbin/nginx"
NGINX_DOWNLOAD_PAGE="https://nginx.org/en/download.html"
NGINX_CONF_DIR="$NGINX_INSTALL_DIR/conf"

# === Ensure curl is installed (early check) ===
if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found, installing..."
    sudo apt update -qq
    sudo apt install -y curl
fi

# === Get current installed version ===
if command -v nginx >/dev/null 2>&1; then
    NGINX_CURRENT_VERSION=$(nginx -v 2>&1 | awk -F/ '{print $2}')
else
    NGINX_CURRENT_VERSION="none"
fi

# === Fetch latest stable version ===
LATEST_VERSION=$(curl -s "$NGINX_DOWNLOAD_PAGE" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | head -1)
TARBALL="nginx-$LATEST_VERSION.tar.gz"
DOWNLOAD_URL="https://nginx.org/download/$TARBALL"

# === Functions ===
install_dependencies() {
    echo "Installing build dependencies..."
    sudo apt update
    sudo apt install -y build-essential libpcre2-dev libssl-dev zlib1g-dev curl
}

build_nginx() {
    echo "Downloading $TARBALL..."
    curl -fLO "$DOWNLOAD_URL"

    echo "Extracting..."
    tar -xzf "$TARBALL"
    cd "nginx-$LATEST_VERSION" || exit 1

    echo "Configuring and compiling..."
    ./configure \
        --prefix="$NGINX_INSTALL_DIR" \
        --with-http_ssl_module \
        --with-pcre \
        --with-http_v2_module \
        --with-stream

    make
    sudo make install

    cd ..
    rm -rf "nginx-$LATEST_VERSION" "$TARBALL"
}

setup_directories_and_config() {
    echo "Setting up NGINX directory structure..."
    sudo mkdir -p \
        "$NGINX_CONF_DIR/sites-available" \
        "$NGINX_CONF_DIR/sites-enabled" \
        "$NGINX_CONF_DIR/conf.d" \
        "$NGINX_INSTALL_DIR/logs" \
        "$NGINX_INSTALL_DIR/html" \
        /var/log/nginx \
        /var/cache/nginx

    # Patch nginx.conf if not already modularized
    if ! grep -q "sites-enabled" "$NGINX_CONF_DIR/nginx.conf"; then
        echo "Modifying nginx.conf to include modular directories..."
        BACKUP_FILE="$NGINX_CONF_DIR/nginx.conf.bak.$(date +%s)"
        sudo cp "$NGINX_CONF_DIR/nginx.conf" "$BACKUP_FILE"

        sudo awk -v conf_dir="$NGINX_CONF_DIR" '
            /http *{/ {
                print $0
                print "    include " conf_dir "/conf.d/*.conf;"
                print "    include " conf_dir "/sites-enabled/*;"
                next
            }
            {print $0}
        ' "$BACKUP_FILE" | sudo tee "$NGINX_CONF_DIR/nginx.conf" >/dev/null
    fi

    # Default example site if none exists
    if [ ! -f "$NGINX_CONF_DIR/sites-available/default.conf" ]; then
        echo "Creating default example site..."
        sudo tee "$NGINX_CONF_DIR/sites-available/default.conf" >/dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;
    root $NGINX_INSTALL_DIR/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        sudo ln -sf "$NGINX_CONF_DIR/sites-available/default.conf" "$NGINX_CONF_DIR/sites-enabled/default.conf"
    fi
}

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
        sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=NGINX from source
After=network.target

[Service]
Type=forking
PIDFile=$NGINX_INSTALL_DIR/logs/nginx.pid
ExecStartPre=$SYSTEM_NGINX_BIN -t -c $NGINX_CONF_DIR/nginx.conf
ExecStart=$SYSTEM_NGINX_BIN -c $NGINX_CONF_DIR/nginx.conf
ExecReload=$SYSTEM_NGINX_BIN -s reload
ExecStop=$SYSTEM_NGINX_BIN -s quit
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

# === Main logic ===
echo "Installed version: $NGINX_CURRENT_VERSION"
echo "Latest version:    $LATEST_VERSION"

if [ "$NGINX_CURRENT_VERSION" = "none" ]; then
    echo "NGINX is not installed. Installing..."
    install_dependencies
    build_nginx
    setup_directories_and_config
    install_system_binary_and_service
elif [ "$NGINX_CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating NGINX from $NGINX_CURRENT_VERSION to $LATEST_VERSION..."
    install_dependencies
    build_nginx
    setup_directories_and_config
    install_system_binary_and_service
else
    echo "NGINX is already up to date."
    setup_directories_and_config
    sudo systemctl restart nginx
fi

echo "✅ NGINX setup complete!"
echo "Configuration path: $NGINX_CONF_DIR"
echo "Enabled sites:      $NGINX_CONF_DIR/sites-enabled"
