#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Logging (PowerShell style)
# ==============================
ts() { date +"%Y-%m-%d %H:%M:%S"; }
log_info()  { echo -e "[$(ts)][INFO ] $*"; }
log_ok()    { echo -e "[$(ts)][OK   ] $*"; }
log_warn()  { echo -e "[$(ts)][WARN ] $*"; }
log_error() { echo -e "[$(ts)][ERROR] $*" >&2; }

# ==============================
# Root check
# ==============================
if [[ $EUID -ne 0 ]]; then
  log_error "Please run as root (sudo)."
  exit 1
fi

# ==============================
# Variables
# ==============================
OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
DOCKER_KEYRING="/etc/apt/keyrings/docker.asc"
DOCKER_SOURCES="/etc/apt/sources.list.d/docker.sources"
DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
TARGET_USER="${SUDO_USER:-root}"

# ==============================
# Functions
# ==============================

remove_old_packages() {
  log_info "Removing old Docker / Podman packages if present..."

  local pkgs
  pkgs=$(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | awk '{print $1}')

  if [[ -n "$pkgs" ]]; then
    apt remove -y $pkgs || true
    log_ok "Old packages removed."
  else
    log_ok "No old Docker-related packages found."
  fi
}

install_prereqs() {
  log_info "Installing prerequisites..."
  apt update
  apt install -y ca-certificates curl
  log_ok "Prerequisites installed."
}

install_gpg_key() {
  log_info "Installing Docker GPG key..."
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o "$DOCKER_KEYRING"
  chmod a+r "$DOCKER_KEYRING"
  log_ok "Docker GPG key installed."
}

configure_repo() {
  log_info "Configuring Docker APT repository ($OS_CODENAME)..."

  cat > "$DOCKER_SOURCES" <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $OS_CODENAME
Components: stable
Signed-By: $DOCKER_KEYRING
EOF

  log_ok "Docker repository configured."
}

install_docker() {
  log_info "Installing Docker Engine and Docker Compose plugin..."
  apt update
  apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  log_ok "Docker and Compose plugin installed."
}

enable_compose_compat() {
  log_info "Ensuring docker-compose compatibility command exists..."

  if command -v docker-compose >/dev/null 2>&1; then
    log_ok "docker-compose command already available."
    return
  fi

  if docker compose version >/dev/null 2>&1; then
    ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null || true
    log_ok "docker-compose compatibility symlink created."
  else
    log_warn "Docker Compose plugin not detected."
  fi
}

configure_daemon() {
  log_info "Configuring Docker daemon (daemon.json)..."

  mkdir -p /etc/docker

  if [[ -f "$DOCKER_DAEMON_JSON" ]]; then
    log_warn "Existing daemon.json found — creating backup."
    cp "$DOCKER_DAEMON_JSON" "$DOCKER_DAEMON_JSON.bak.$(date +%s)"
  fi

  cat > "$DOCKER_DAEMON_JSON" <<'EOF'
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF

  log_ok "Docker daemon configuration written."
}

start_docker() {
  log_info "Enabling and starting Docker service..."
  systemctl enable docker
  systemctl restart docker

  if systemctl is-active --quiet docker; then
    log_ok "Docker service is running."
  else
    log_error "Docker service failed to start."
    systemctl status docker --no-pager
    exit 1
  fi
}

add_user_to_group() {
  if [[ "$TARGET_USER" == "root" ]]; then
    log_warn "Running as root directly — skipping docker group assignment."
    return
  fi

  log_info "Adding user '$TARGET_USER' to docker group..."
  usermod -aG docker "$TARGET_USER"
  log_ok "User '$TARGET_USER' added to docker group."
  log_warn "User must log out and log back in for group change to apply."
}

run_test_container() {
  log_info "Running test container (hello-world)..."
  docker run --rm hello-world
  log_ok "Hello-world container executed successfully."
}

# ==============================
# Main
# ==============================
log_info "Starting Docker + Docker Compose installation on Debian $OS_CODENAME"

remove_old_packages
install_prereqs
install_gpg_key
configure_repo
install_docker
enable_compose_compat
configure_daemon
start_docker
add_user_to_group
run_test_container

log_ok "Docker and Docker Compose installation completed successfully ✅"
