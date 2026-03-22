#!/usr/bin/env bash
# install_certbot.sh
# Universal Certbot installer for Debian 13 (supports both NGINX and Apache)
# Only that you need just select a key --nginx or --apache.
# Example for nginx sudo ./install_certbot.sh --nginx
# Example for apache sudo ./install_certbot.sh --apache

set -euo pipefail

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Usage function
usage() {
  echo -e "${YELLOW}Usage:${RESET} $0 [--nginx | --apache]"
  echo -e "Example: sudo $0 --nginx"
  exit 1
}

# Ensure root privileges
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Please run this script as root or with sudo.${RESET}"
  exit 1
fi

# Parse argument
if [[ $# -ne 1 ]]; then
  usage
fi

case "$1" in
  --nginx)
    PLUGIN="certbot-nginx"
    SERVER_TYPE="NGINX"
    ;;
  --apache)
    PLUGIN="certbot-apache"
    SERVER_TYPE="Apache"
    ;;
  *)
    usage
    ;;
esac

# Update and install dependencies
echo -e "${YELLOW}Updating package lists...${RESET}"
apt update -y

echo -e "${YELLOW}Installing dependencies...${RESET}"
apt install -y ca-certificates python3 python3-venv python3-dev libaugeas-dev gcc curl gnupg2

# Uninstall any old Certbot packages
if dpkg -l | grep -q certbot; then
  echo -e "${YELLOW}Removing existing apt-based Certbot packages...${RESET}"
  apt remove -y certbot python3-certbot* || true
fi

# Virtual environment path
VENV_DIR="/opt/certbot"

# Create or reuse venv
if [[ -d "$VENV_DIR" ]]; then
  echo -e "${YELLOW}Virtual environment already exists — upgrading Certbot...${RESET}"
else
  echo -e "${YELLOW}Creating Python virtual environment at $VENV_DIR...${RESET}"
  python3 -m venv "$VENV_DIR"
fi

# Upgrade pip and install Certbot + plugin
echo -e "${YELLOW}Installing latest Certbot and $PLUGIN plugin...${RESET}"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install --upgrade certbot "$PLUGIN"

# Symlink for global access
ln -sf "$VENV_DIR/bin/certbot" /usr/local/bin/certbot

# Verify
if command -v certbot >/dev/null 2>&1; then
  echo -e "${GREEN}Certbot installed successfully via venv: $(certbot --version)${RESET}"
else
  echo -e "${RED}Certbot installation failed.${RESET}"
  exit 1
fi

# Enable timer (if available)
if systemctl list-unit-files | grep -q certbot.timer; then
  echo -e "${YELLOW}Enabling Certbot auto-renewal timer...${RESET}"
  systemctl enable --now certbot.timer || true
else
  echo -e "${YELLOW}No systemd timer found — you can add a cron job manually if desired.${RESET}"
fi

# Success message
echo -e "${GREEN}All done! Certbot is ready to use with $SERVER_TYPE.${RESET}"
echo -e "Run: ${YELLOW}sudo certbot --$1${RESET} to obtain certificates."
