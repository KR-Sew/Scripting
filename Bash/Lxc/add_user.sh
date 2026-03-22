#!/usr/bin/env bash

# ================================
# User Bootstrap Script (Debian/Ubuntu/LXC)
# ================================

set -euo pipefail

# -------- CONFIG --------
USERNAME="${1:-}"
ADD_SUDO="${2:-yes}"

# -------- COLORS --------
INFO="\033[1;34m[INFO]\033[0m"
WARN="\033[1;33m[WARN]\033[0m"
ERROR="\033[1;31m[ERROR]\033[0m"

# -------- FUNCTIONS --------

log_info()  { echo -e "$INFO  $*"; }
log_warn()  { echo -e "$WARN  $*"; }
log_error() { echo -e "$ERROR $*"; }

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_error "Run as root"
        exit 1
    fi
}

check_input() {
    if [[ -z "$USERNAME" ]]; then
        log_error "Usage: $0 <username> [sudo=yes|no]"
        exit 1
    fi
}

ensure_user() {
    if id "$USERNAME" &>/dev/null; then
        log_warn "User '$USERNAME' already exists"
    else
        log_info "Creating user '$USERNAME'"
        useradd -m -s /bin/bash "$USERNAME"
    fi
}

ensure_home() {
    if [[ ! -d "/home/$USERNAME" ]]; then
        log_warn "Home directory missing, creating..."
        install -d -m 0750 -o "$USERNAME" -g "$USERNAME" "/home/$USERNAME"
    fi
}

ensure_skel() {
    if [[ ! -f "/home/$USERNAME/.bashrc" ]]; then
        log_warn "Copying skeleton files"
        cp -a /etc/skel/. "/home/$USERNAME/"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
    fi
}

ensure_shell() {
    CURRENT_SHELL=$(getent passwd "$USERNAME" | cut -d: -f7)

    if [[ "$CURRENT_SHELL" != "/bin/bash" ]]; then
        log_info "Setting shell to /bin/bash"
        usermod -s /bin/bash "$USERNAME"
    fi
}

ensure_bashrc_loading() {
    if ! grep -q ".bashrc" "/home/$USERNAME/.profile"; then
        log_warn "Fixing .profile to load .bashrc"

        cat >> "/home/$USERNAME/.profile" <<'EOF'

# Ensure .bashrc is loaded
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
    fi
}

ensure_sudo() {
    if [[ "$ADD_SUDO" == "yes" ]]; then
        if ! command -v sudo &>/dev/null; then
            log_info "Installing sudo"
            apt-get update -y
            apt-get install -y sudo
        fi

        log_info "Adding '$USERNAME' to sudo group"
        usermod -aG sudo "$USERNAME"
    fi
}

final_info() {
    log_info "User '$USERNAME' is ready ✅"
    echo
    echo "Login options:"
    echo "  su - $USERNAME"
    echo "  sudo -iu $USERNAME"
    echo "  lxc exec <ctr> -- sudo -iu $USERNAME"
}

# -------- MAIN --------

check_root
check_input

ensure_user
ensure_home
ensure_skel
ensure_shell
ensure_bashrc_loading
ensure_sudo

final_info