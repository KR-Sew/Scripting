#!/usr/bin/env bash
# certbot_install_nginx_venv.sh
# Install latest Certbot for NGINX on Debian 13 safely (compatible with NGINX built from source)

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
apt install -y ca-certificates python3 python3-venv python3-dev libaugeas-dev gcc curl gnupg2

# Step 1: Remove any OS-packaged Certbot to avoid conflicts
if dpkg -l | grep -q certbot; then
  echo -e "${YELLOW}Removing existing Certbot packages (apt-managed)...${RESET}"
  apt remove -y certbot python3-certbot* || true
fi

# Step 2: Create Python venv for Certbot
VENV_DIR="/opt/certbot"
if [[ -d "$VENV_DIR" ]]; then
  echo -e "${YELLOW}Virtual environment already exists at $VENV_DIR — upgrading Certbot...${RESET}"
else
  echo -e "${YELLOW}Creating Python virtual environment for Certbot...${RESET}"
  python3 -m venv "$VENV_DIR"
fi

# Step 3: Upgrade pip and install latest Certbot inside venv
echo -e "${YELLOW}Installing or upgrading Certbot inside the venv...${RESET}"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install --upgrade certbot certbot-nginx

# Step 4: Create symbolic link for easier access
if [[ ! -f /usr/local/bin/certbot ]]; then
  ln -sf "$VENV_DIR/bin/certbot" /usr/local/bin/certbot
  echo -e "${GREEN}Symlink created: /usr/local/bin/certbot → $VENV_DIR/bin/certbot${RESET}"
fi

# Step 5: Verify installation
if command -v certbot >/dev/null 2>&1; then
  echo -e "${GREEN}Certbot installed successfully via venv: $(certbot --version)${RESET}"
else
  echo -e "${RED}Certbot installation failed.${RESET}"
  exit 1
fi

# Step 6: Enable systemd timer for auto-renewal (if systemd is present)
if systemctl list-unit-files | grep -q certbot.timer; then
  echo -e "${YELLOW}Enabling Certbot auto-renewal timer...${RESET}"
  systemctl enable --now certbot.timer || true
else
  echo -e "${YELLOW}No systemd timer found — you can add a cron job manually if desired.${RESET}"
fi

echo -e "${GREEN}All done! Certbot is ready to use with NGINX.${RESET}"
echo -e "Run: ${YELLOW}sudo certbot --nginx${RESET} to obtain or renew certificates."
