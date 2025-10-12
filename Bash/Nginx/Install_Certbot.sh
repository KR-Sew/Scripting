#!/usr/bin/env bash
#============================================================
# Script: install_certbot.sh
# Purpose: Install Certbot on Debian 13 (Trixie)
# Author: Andrew’s assistant (GPT-5)
#============================================================

set -euo pipefail

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Please run this script as root or with sudo.${RESET}"
  exit 1
fi

echo -e "${YELLOW}Updating package lists...${RESET}"
apt update -y

echo -e "${YELLOW}Installing dependencies...${RESET}"
apt install -y software-properties-common curl gnupg2 lsb-release ca-certificates

# Check if certbot already installed
if command -v certbot >/dev/null 2>&1; then
  echo -e "${GREEN}Certbot is already installed: $(certbot --version)${RESET}"
else
  echo -e "${YELLOW}Installing Certbot...${RESET}"
  apt install -y certbot python3-certbot-nginx python3-certbot-apache || {
    echo -e "${RED}Failed to install Certbot packages.${RESET}"
    exit 1
  }
fi

# Verify installation
if command -v certbot >/dev/null 2>&1; then
  echo -e "${GREEN}Certbot installed successfully: $(certbot --version)${RESET}"
else
  echo -e "${RED}Certbot installation failed.${RESET}"
  exit 1
fi

# Optional: enable auto-renewal timer
echo -e "${YELLOW}Enabling auto-renewal service...${RESET}"
systemctl enable --now certbot.timer

echo -e "${GREEN}All done! Certbot is ready to use.${RESET}"
echo -e "Run: ${YELLOW}sudo certbot --nginx${RESET} or ${YELLOW}sudo certbot --apache${RESET} to obtain certificates."
