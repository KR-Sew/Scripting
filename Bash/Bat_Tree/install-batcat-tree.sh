#!/usr/bin/env bash

# Installs batcat and tree on Debian.
# Debian provides the batcat command through the package named "bat".

set -Eeuo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

info()    { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }
success() { printf "${GREEN}[ OK ]${RESET} %s\n" "$*"; }
warning() { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
error()   { printf "${RED}[FAIL]${RESET} %s\n" "$*" >&2; }

on_error() {
    error "Installation failed on line $1."
}
trap 'on_error "$LINENO"' ERR

check_debian() {
    if [[ ! -r /etc/os-release ]]; then
        error "Cannot identify the operating system: /etc/os-release is missing."
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    if [[ "${ID:-}" != "debian" && "${ID_LIKE:-}" != *debian* ]]; then
        error "This script is intended for Debian or a Debian-based system."
        exit 1
    fi

    success "Detected ${PRETTY_NAME:-a Debian-based system}."
}

configure_privileges() {
    if (( EUID == 0 )); then
        APT=(apt-get)
    elif command -v sudo >/dev/null 2>&1; then
        APT=(sudo apt-get)
    else
        error "Run this script as root, or install and configure sudo."
        exit 1
    fi
}

install_packages() {
    local packages=()

    dpkg-query -W -f='${Status}' bat 2>/dev/null | grep -q 'ok installed' \
        || packages+=(bat)
    dpkg-query -W -f='${Status}' tree 2>/dev/null | grep -q 'ok installed' \
        || packages+=(tree)

    if (( ${#packages[@]} == 0 )); then
        warning "bat and tree are already installed."
        return
    fi

    info "Updating the APT package index..."
    "${APT[@]}" update

    info "Installing: ${packages[*]}"
    "${APT[@]}" install -y --no-install-recommends "${packages[@]}"
}

verify_installation() {
    local failed=0

    if command -v batcat >/dev/null 2>&1; then
        success "$(batcat --version)"
    else
        error "The batcat command was not found after installation."
        failed=1
    fi

    if command -v tree >/dev/null 2>&1; then
        success "$(tree --version | head -n 1)"
    else
        error "The tree command was not found after installation."
        failed=1
    fi

    (( failed == 0 )) || exit 1
}

main() {
    printf '\n%s\n' "Debian batcat and tree installer"
    printf '%s\n' "================================"

    check_debian
    configure_privileges
    install_packages
    verify_installation

    success "Installation completed successfully."
}

main "$@"
