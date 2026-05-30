#!/usr/bin/env bash
set -euo pipefail

# ---------- Helpers ----------
log()  { echo -e "\e[32m[INFO]\e[0m  $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m  $*"; }
err()  { echo -e "\e[31m[ERR ]\e[0m  $*" >&2; }

if [[ $EUID -ne 0 ]]; then
  err "Please run as root (use sudo)."
  exit 1
fi

# ---------- Variables ----------
OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
DOCKER_KEYRING="/etc/apt/keyrings/docker.asc"
DOCKER_SOURCES="/etc/apt/sources.list.d/docker.sources"

# ---------- Remove old/conflicting packages ----------
log "Removing old Docker / Podman packages if present..."

OLD_PKGS=$(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | awk '{print $1}')

if [[ -n "$OLD_PKGS" ]]; then
  apt remove -y $OLD_PKGS || true
else
  log "No old Docker-related packages found."
fi

# ---------- Base packages ----------
log "Updating APT and installing prerequisites..."
apt update
apt install -y ca-certificates curl

# ---------- Docker GPG key ----------
log "Installing Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg -o "$DOCKER_KEYRING"
chmod a+r "$DOCKER_KEYRING"

# ---------- Docker repository ----------
log "Configuring Docker repository for Debian ($OS_CODENAME)..."

cat > "$DOCKER_SOURCES" <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $OS_CODENAME
Components: stable
Signed-By: $DOCKER_KEYRING
EOF

# ---------- Install Docker ----------
log "Installing Docker Engine and plugins..."
apt update
apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ---------- Enable & start service ----------
log "Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

if systemctl is-active --quiet docker; then
  log "Docker service is running."
else
  err "Docker service is NOT running!"
  systemctl status docker --no-pager
  exit 1
fi

# ---------- Test container ----------
log "Running test container (hello-world)..."
docker run --rm hello-world

log "Docker installation completed successfully ✅"