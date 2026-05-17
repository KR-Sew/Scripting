#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Colors
# ============================================================

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# ============================================================
# Variables
# ============================================================

NGINX_BIN="/usr/local/nginx/sbin/nginx"
SRC_DIR="/usr/local/src"
BACKUP_DIR="/usr/local/nginx-backups"

# ============================================================
# Helper Functions
# ============================================================

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_ok() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERR ]${RESET} $1"
}

# ============================================================
# Checks
# ============================================================

if [[ ! -x "$NGINX_BIN" ]]; then
    log_error "NGINX binary not found at: $NGINX_BIN"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    log_warn "curl not found. Installing..."
    sudo apt-get update -qq
    sudo apt-get install -y curl
fi

if ! command -v make >/dev/null 2>&1; then
    log_warn "Build tools not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y build-essential
fi

# ============================================================
# Detect Installed Version
# ============================================================

NGINX_VERSION=$($NGINX_BIN -v 2>&1 | awk -F/ '{print $2}')

log_ok "Detected NGINX version: ${NGINX_VERSION}"

# ============================================================
# Read Existing Configure Arguments
# ============================================================

CONFIGURE_ARGS=$($NGINX_BIN -V 2>&1 | \
grep 'configure arguments:' | \
sed 's/^.*arguments: //')

log_info "Current configure arguments:"
echo "$CONFIGURE_ARGS"

# ============================================================
# Remove old stream flags if exist
# ============================================================

CONFIGURE_ARGS=$(echo "$CONFIGURE_ARGS" | \
sed 's/--with-stream//g' | \
sed 's/--with-stream_ssl_module//g' | \
sed 's/--with-stream_ssl_preread_module//g')

# ============================================================
# Add required stream modules
# ============================================================

NEW_CONFIGURE_ARGS="$CONFIGURE_ARGS \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module"

log_info "New configure arguments:"
echo "$NEW_CONFIGURE_ARGS"

# ============================================================
# Prepare Directories
# ============================================================

sudo mkdir -p "$SRC_DIR"
sudo mkdir -p "$BACKUP_DIR"

cd "$SRC_DIR"

# ============================================================
# Download Source
# ============================================================

TARBALL="nginx-${NGINX_VERSION}.tar.gz"
DOWNLOAD_URL="https://nginx.org/download/${TARBALL}"

if [[ ! -f "$TARBALL" ]]; then
    log_info "Downloading NGINX source..."
    curl -fLO "$DOWNLOAD_URL"
else
    log_warn "Source archive already exists: $TARBALL"
fi

# ============================================================
# Extract Source
# ============================================================

if [[ -d "nginx-${NGINX_VERSION}" ]]; then
    log_warn "Removing old source directory..."
    rm -rf "nginx-${NGINX_VERSION}"
fi

log_info "Extracting source..."
tar -xzf "$TARBALL"

cd "nginx-${NGINX_VERSION}"

# ============================================================
# Configure
# ============================================================

log_info "Configuring NGINX..."

eval ./configure "$NEW_CONFIGURE_ARGS"

# ============================================================
# Compile
# ============================================================

CPU_CORES=$(nproc)

log_info "Compiling using ${CPU_CORES} CPU threads..."

make -j"$CPU_CORES"

# ============================================================
# Backup Existing Binary
# ============================================================

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

BACKUP_FILE="${BACKUP_DIR}/nginx-${NGINX_VERSION}-${TIMESTAMP}"

log_info "Backing up existing binary..."
sudo cp "$NGINX_BIN" "$BACKUP_FILE"

log_ok "Backup created:"
echo "       $BACKUP_FILE"

# ============================================================
# Replace Binary Safely
# ============================================================

log_info "Stopping NGINX..."

sudo systemctl stop nginx

log_info "Installing new binary..."

sudo install -m 755 objs/nginx "$NGINX_BIN"

log_info "Starting NGINX..."

sudo systemctl start nginx

# ============================================================
# Verify Modules
# ============================================================

VERIFY_OUTPUT=$($NGINX_BIN -V 2>&1)

echo "$VERIFY_OUTPUT"

if echo "$VERIFY_OUTPUT" | grep -q -- '--with-stream_ssl_preread_module'; then
    log_ok "ssl_preread module successfully installed!"
else
    log_error "ssl_preread module NOT found after build!"
    exit 1
fi

# ============================================================
# Test Configuration
# ============================================================

log_info "Testing NGINX configuration..."

sudo "$NGINX_BIN" -t

# ============================================================
# Reload Service
# ============================================================

log_info "Reloading NGINX..."

sudo systemctl reload nginx

# ============================================================
# Done
# ============================================================

echo
log_ok "NGINX stream modules installed successfully!"
echo
echo "Enabled modules:"
echo "  ✔ --with-stream"
echo "  ✔ --with-stream_ssl_module"
echo "  ✔ --with-stream_ssl_preread_module"
echo
echo "You can now use directives like:"
echo "  ssl_preread on;"
echo