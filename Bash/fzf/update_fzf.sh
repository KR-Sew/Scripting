#!/usr/bin/env bash

# ============================================================================
# Description: Check installed fzf version and update from GitHub if needed
# Platform:    Debian / Ubuntu
# Requires:    curl, tar
# Usage:
#   chmod +x update-fzf.sh
#   ./update-fzf.sh
#
# Optional:
#   INSTALL_DIR=/usr/local/bin ./update-fzf.sh
# ============================================================================

set -Eeuo pipefail

# -------------------------------
# Configuration
# -------------------------------
REPO="junegunn/fzf"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
TMP_DIR="$(mktemp -d)"
ARCH="$(uname -m)"

# -------------------------------
# Logging
# -------------------------------
log_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

log_ok() {
    echo -e "\e[32m[ OK ]\e[0m $1"
}

log_warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[FAIL]\e[0m $1"
}

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# -------------------------------
# Check dependencies
# -------------------------------
for cmd in curl tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Required command not found: $cmd"
        exit 1
    fi
done

# -------------------------------
# Detect architecture
# -------------------------------
case "$ARCH" in
    x86_64)
        FZF_ARCH="linux_amd64"
        ;;
    aarch64 | arm64)
        FZF_ARCH="linux_arm64"
        ;;
    armv7l)
        FZF_ARCH="linux_armv7"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected architecture: $ARCH ($FZF_ARCH)"

# -------------------------------
# Get installed version
# -------------------------------
INSTALLED_VERSION="not installed"

if command -v fzf >/dev/null 2>&1; then
    INSTALLED_VERSION="$(fzf --version | awk '{print $1}')"
fi

log_info "Installed version: $INSTALLED_VERSION"

# -------------------------------
# Get latest version from GitHub
# -------------------------------
log_info "Checking latest release on GitHub..."

LATEST_VERSION="$(
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"v?([^"]+)".*/\1/'
)"

if [[ -z "$LATEST_VERSION" ]]; then
    log_error "Unable to fetch latest version from GitHub"
    exit 1
fi

log_info "Latest version: $LATEST_VERSION"

# -------------------------------
# Compare versions
# -------------------------------
if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
    log_ok "fzf is already up to date"
    exit 0
fi

log_warn "Update required"

# -------------------------------
# Download release
# -------------------------------
ARCHIVE_NAME="fzf-${LATEST_VERSION}-${FZF_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}/${ARCHIVE_NAME}"

log_info "Downloading:"
echo "       $DOWNLOAD_URL"

curl -fL "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE_NAME"

# -------------------------------
# Extract archive
# -------------------------------
log_info "Extracting archive..."

tar -xzf "$TMP_DIR/$ARCHIVE_NAME" -C "$TMP_DIR"

if [[ ! -f "$TMP_DIR/fzf" ]]; then
    log_error "fzf binary not found after extraction"
    exit 1
fi

# -------------------------------
# Install binary
# -------------------------------
log_info "Installing fzf to: $INSTALL_DIR"

sudo install -m 0755 "$TMP_DIR/fzf" "$INSTALL_DIR/fzf"

# -------------------------------
# Verify installation
# -------------------------------
NEW_VERSION="$(fzf --version | awk '{print $1}')"

if [[ "$NEW_VERSION" == "$LATEST_VERSION" ]]; then
    log_ok "fzf updated successfully to version $NEW_VERSION"
else
    log_error "Update verification failed"
    exit 1
fi