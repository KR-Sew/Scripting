#!/usr/bin/env bash
set -euo pipefail

VERSION="2.0"

# ---------------- COLORS ----------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

info()  { echo -e "${GREEN}[INFO]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }
section() { echo -e "\n${BLUE}========== $1 ==========${RESET}"; }

# ---------------- DEFAULT FLAGS ----------------
TARGET="8.8.8.8"
IFACE=""
AUTO_INSTALL=false
SAVE_FILE=""
DIFF_FILE=""

# ---------------- ARGUMENT PARSER ----------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --iface)
      IFACE="$2"
      shift 2
      ;;
    --install-tools)
      AUTO_INSTALL=true
      shift
      ;;
    --save)
      SAVE_FILE="$2"
      shift 2
      ;;
    --diff)
      DIFF_FILE="$2"
      shift 2
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
done

# ---------------- TOOL CHECKER ----------------
require_tool() {
    local cmd="$1"
    local pkg="$2"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        warn "$cmd not found"
        if [[ "$AUTO_INSTALL" == true ]]; then
            info "Installing $pkg..."
            apt update -qq
            apt install -y "$pkg"
        fi
    fi
}

# ---------------- MODULES ----------------
check_interfaces() {
    section "INTERFACES"
    ip -br addr
}

check_routes() {
    section "ROUTES"
    ip route show
    echo
    ip rule show
}

check_dns() {
    section "DNS"
    cat /etc/resolv.conf || true
}

check_connectivity() {
    section "CONNECTIVITY TEST ($TARGET)"
    ping -c 2 "$TARGET" || warn "Ping failed"
    tracepath "$TARGET" || true
}

# ---------------- COLLECT SNAPSHOT ----------------
collect_snapshot() {
    {
        ip -br addr
        ip route show
        ip rule show
        ss -tuln
    }
}

# ---------------- MAIN ----------------
require_tool ip iproute2
require_tool ping iputils-ping
require_tool tracepath iputils-ping
require_tool ss iproute2

if [[ -n "$SAVE_FILE" ]]; then
    info "Saving snapshot to $SAVE_FILE"
    collect_snapshot > "$SAVE_FILE"
    exit 0
fi

if [[ -n "$DIFF_FILE" ]]; then
    info "Comparing current state with $DIFF_FILE"
    TMP=$(mktemp)
    collect_snapshot > "$TMP"
    diff --color=always "$DIFF_FILE" "$TMP" || true
    rm "$TMP"
    exit 0
fi

check_interfaces
check_routes
check_dns
check_connectivity