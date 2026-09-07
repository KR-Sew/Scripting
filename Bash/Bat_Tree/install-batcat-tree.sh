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

configure_bat_command() {
    local target_user target_home target_group bin_dir bashrc_file batcat_path
    local path_entry='export PATH="$HOME/.local/bin:$PATH"'

    target_user="${SUDO_USER:-$(id -un)}"
    target_home="$(getent passwd "$target_user" | cut -d: -f6)"
    target_group="$(id -gn "$target_user")"
    batcat_path="$(command -v batcat)"

    if [[ -z "$target_home" ]]; then
        error "Could not determine the home directory for user '$target_user'."
        exit 1
    fi

    bin_dir="$target_home/.local/bin"
    bashrc_file="$target_home/.bashrc"

    info "Configuring the 'bat' command for user '$target_user'..."

    if (( EUID == 0 )); then
        install -d -m 0755 -o "$target_user" -g "$target_group" "$bin_dir"
        ln -sfn "$batcat_path" "$bin_dir/bat"
        chown -h "$target_user:$target_group" "$bin_dir/bat"
        touch "$bashrc_file"
        chown "$target_user:$target_group" "$bashrc_file"
    else
        mkdir -p "$bin_dir"
        ln -sfn "$batcat_path" "$bin_dir/bat"
        touch "$bashrc_file"
    fi

    if grep -Fqx "$path_entry" "$bashrc_file"; then
        warning "~/.local/bin is already configured in $bashrc_file."
    else
        printf '\n%s\n' "$path_entry" >> "$bashrc_file"
        success "Added ~/.local/bin to PATH in $bashrc_file."
    fi

    export PATH="$bin_dir:$PATH"

    if [[ "$(command -v bat)" == "$bin_dir/bat" ]]; then
        success "The 'bat' command now points to $batcat_path."
    else
        error "The 'bat' command could not be configured."
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
    configure_bat_command

    success "Installation completed successfully."
    info "Run 'source ~/.bashrc && bat --version' or open a new terminal to refresh your current shell."
}

main "$@"
