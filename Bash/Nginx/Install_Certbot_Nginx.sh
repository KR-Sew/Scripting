#!/usr/bin/env bash
#============================================================
# Script: install_certbot_nginx.sh
# Purpose: Install Certbot with NGINX support on Debian 13 (Trixie)
# Author: Andrew’s assistant (GPT-5)
#============================================================

set -euo pipefail

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Check privileges
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Please run this script as root or with sudo.${RESET}"
  exit 1
fi

# Update and install dependencies
echo -e "${YELLOW}Updating package lists...${RESET}"
apt update -y

echo -e "${YELLOW}Installing required packages...${RESET}"
apt install -y software-properties-common curl gnupg2 lsb-release ca-certificates

# Ensure NGINX is installed
if ! command -v nginx >/dev/null 2>&1; then
  echo -e "${YELLOW}NGINX is not installed. Installing...${RESET}"
  apt install -y nginx
  systemctl enable --now nginx
else
  echo -e "${GREEN}NGINX already installed: $(nginx -v 2>&1)${RESET}"
fi

# Install Certbot and NGINX plugin
if ! command -v certbot >/dev/null 2>&1; then
  echo -e "${YELLOW}Installing Certbot with NGINX plugin...${RESET}"
  apt install -y certbot python3-certbot-nginx
else
  echo -e "${GREEN}Certbot already installed: $(certbot --version)${RESET}"
fi

# Enable and start auto-renewal timer
echo -e "${YELLOW}Enabling Certbot auto-renewal timer...${RESET}"
systemctl enable --now certbot.timer

# Verify installations
if ! command -v certbot >/dev/null 2>&1 || ! command -v nginx >/dev/null 2>&1; then
  echo -e "${RED}Certbot or NGINX installation failed.${RESET}"
  exit 1
fi

echo -e "${GREEN}Certbot and NGINX installed successfully.${RESET}"

# Ask for domain and email
read -rp "Enter your domain name (e.g. example.com): " DOMAIN
read -rp "Enter your email address for Let's Encrypt notifications: " EMAIL

# Validate domain input
if [[ -z "$DOMAIN" ]]; then
  echo -e "${RED}Domain cannot be empty.${RESET}"
  exit 1
fi

# Create NGINX server block if not exists
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
if [[ ! -f "$NGINX_CONF" ]]; then
  echo -e "${YELLOW}Creating NGINX configuration for $DOMAIN...${RESET}"
  cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root /var/www/$DOMAIN/html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

  mkdir -p "/var/www/$DOMAIN/html"
  echo "<h1>$DOMAIN is working!</h1>" > "/var/www/$DOMAIN/html/index.html"

  ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
  nginx -t && systemctl reload nginx
else
  echo -e "${GREEN}NGINX config for $DOMAIN already exists.${RESET}"
fi

# Obtain certificate
echo -e "${YELLOW}Requesting Let's Encrypt certificate for $DOMAIN...${RESET}"
certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email

# Verify success
if [[ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]]; then
  echo -e "${GREEN}Certificate obtained successfully for $DOMAIN.${RESET}"
else
  echo -e "${RED}Failed to obtain certificate for $DOMAIN.${RESET}"
  exit 1
fi

# Set up reload hook
HOOK_PATH="/etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh"
if [[ ! -f "$HOOK_PATH" ]]; then
  echo -e "${YELLOW}Adding NGINX reload hook for certificate renewal...${RESET}"
  cat > "$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
systemctl reload nginx
HOOK
  chmod +x "$HOOK_PATH"
fi

echo -e "${GREEN}NGINX reload hook configured.${RESET}"
echo -e "${GREEN}All done! Certbot + NGINX are fully configured.${RESET}"
echo
echo -e "👉 Test auto-renewal with: ${YELLOW}sudo certbot renew --dry-run${RESET}"
echo -e "👉 Your site: http://${DOMAIN}/"
