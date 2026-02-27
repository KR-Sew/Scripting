#!/usr/bin/env bash

# ========================================
# Install / Update AWS CLI v2
# Debian / Ubuntu
# ========================================

set -e

LOG_TIME() {
  date +"%Y-%m-%d %H:%M:%S"
}

log() {
  LEVEL=$1
  MESSAGE=$2

  case $LEVEL in
    INFO)  COLOR="\033[0;36m" ;;
    OK)    COLOR="\033[0;32m" ;;
    WARN)  COLOR="\033[1;33m" ;;
    ERROR) COLOR="\033[0;31m" ;;
  esac

  echo -e "[ $(LOG_TIME) ][${LEVEL}] ${COLOR}${MESSAGE}\033[0m"
}

get_aws_version() {
  if command -v aws >/dev/null 2>&1; then
    aws --version 2>/dev/null | awk -F/ '{print $2}' | awk '{print $1}'
  fi
}

log INFO "Checking AWS CLI installation..."

INSTALLED_VERSION=$(get_aws_version)

if [ -n "$INSTALLED_VERSION" ]; then
  log OK "Detected AWS CLI version $INSTALLED_VERSION"
else
  log WARN "AWS CLI not installed"
fi

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

log INFO "Installing prerequisites..."
sudo apt-get update -qq
sudo apt-get install -y curl unzip >/dev/null

log INFO "Downloading latest AWS CLI..."
curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip -q awscliv2.zip

if [ -n "$INSTALLED_VERSION" ]; then
  log INFO "Updating AWS CLI..."
  sudo ./aws/install --update
else
  log INFO "Installing AWS CLI..."
  sudo ./aws/install
fi

cd ~
rm -rf "$TMP_DIR"

NEW_VERSION=$(get_aws_version)

if [ -n "$NEW_VERSION" ]; then
  log OK "AWS CLI installed successfully. Version: $NEW_VERSION"
else
  log ERROR "Installation failed"
  exit 1
fi