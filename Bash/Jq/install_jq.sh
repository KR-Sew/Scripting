#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# jq Updater Script (Build from GitHub Source)
# Style: Modular / Colored Logs / Argument Parser
# ============================================================

REPO="jqlang/jq"
INSTALL_PREFIX="/usr/local"
TMP_DIR="/tmp/jq-build"

FORCE_INSTALL=false
CHECK_ONLY=false

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# ------------------------------------------------------------
# Logging helpers
# ------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $*"
}

log_ok() {
    echo -e "${GREEN}[OK]${RESET} $*"
}

# ------------------------------------------------------------
# Dependency installation
# ------------------------------------------------------------

install_dependencies() {

    log_info "Checking required build tools..."

    local packages=(
        git
        curl
        build-essential
        autoconf
        automake
        libtool
    )

    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            log_warn "Installing missing package: $pkg"
            sudo apt-get update -qq
            sudo apt-get install -y "$pkg"
        fi
    done
}

# ------------------------------------------------------------
# Get installed jq version
# ------------------------------------------------------------

get_installed_version() {

    if command -v jq >/dev/null 2>&1; then
        jq --version | cut -d- -f2
    else
        echo "none"
    fi
}

# ------------------------------------------------------------
# Get latest version from GitHub
# ------------------------------------------------------------

get_latest_version() {

    curl -s https://api.github.com/repos/$REPO/releases/latest \
        | grep '"tag_name"' \
        | cut -d '"' -f4 \
        | sed 's/^jq-//'
}

# ------------------------------------------------------------
# Version comparison
# ------------------------------------------------------------

is_update_needed() {

    local installed="$1"
    local latest="$2"

    if [[ "$installed" == "none" ]]; then
        return 0
    fi

    if [[ "$installed" != "$latest" ]]; then
        return 0
    fi

    return 1
}

# ------------------------------------------------------------
# Build and install jq
# ------------------------------------------------------------

build_and_install() {

    log_info "Preparing build directory..."

    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    cd "$TMP_DIR"

    log_info "Cloning jq repository..."
    git clone --recurse-submodules https://github.com/$REPO.git

    cd jq

    log_info "Checking out latest release..."
    git checkout "jq-$LATEST_VERSION"

    log_info "Updating submodules..."
    git submodule update --init --recursive

    log_info "Bootstrapping build..."
    autoreconf -fi

    log_info "Configuring..."
    ./configure --prefix="$INSTALL_PREFIX"

    log_info "Building jq..."
    make -j"$(nproc)"

    log_info "Installing jq..."
    sudo make install

    log_info "Refreshing linker cache..."
    sudo ldconfig

    log_ok "jq $LATEST_VERSION installed successfully!"
}

# ------------------------------------------------------------
# Argument parser
# ------------------------------------------------------------

parse_args() {

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --check)
                CHECK_ONLY=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo
                echo "Options:"
                echo "  --check     Only check versions"
                echo "  --force     Force reinstall"
                echo "  -h          Show help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Main logic
# ------------------------------------------------------------

main() {

    parse_args "$@"

    install_dependencies

    INSTALLED_VERSION=$(get_installed_version)
    LATEST_VERSION=$(get_latest_version)

    log_info "Installed version: ${INSTALLED_VERSION}"
    log_info "Latest version:    ${LATEST_VERSION}"

    if [[ "$CHECK_ONLY" == true ]]; then
        exit 0
    fi

    if [[ "$FORCE_INSTALL" == true ]]; then
        log_warn "Force install enabled"
        build_and_install
        exit 0
    fi

    if is_update_needed "$INSTALLED_VERSION" "$LATEST_VERSION"; then
        log_info "Updating jq..."
        build_and_install
    else
        log_ok "jq is already up to date"
    fi
}

main "$@"