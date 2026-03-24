#!/usr/bin/env bash

# ==========================================================
# Certbot Certificate Checker / Renewer
# Author: Andrew-style script :)
# ==========================================================

set -o errexit
set -o pipefail
set -o nounset

# ---------- Colors ----------
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- Logging ----------
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $*"
}

# ---------- Defaults ----------
MODE="check"
THRESHOLD_DAYS=30

# ---------- Help ----------
usage() {
cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --check           Check certificate expiration (default)
  --renew           Renew certificates if expired or near expiration
  --days N          Renew/check if expiration is within N days (default: 30)
  --help            Show this help

Examples:
  Check certificates:
      script.sh --check

  Renew certificates expiring within 15 days:
      script.sh --renew --days 15

EOF
}

# ---------- Argument parser ----------
parse_args() {

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check)
                MODE="check"
                ;;
            --renew)
                MODE="renew"
                ;;
            --days)
                THRESHOLD_DAYS="$2"
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown parameter: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done

}

# ---------- Dependency check ----------
check_dependencies() {

    if ! command -v certbot >/dev/null 2>&1; then
        log_error "certbot not found"
        exit 1
    fi

    if ! command -v date >/dev/null 2>&1; then
        log_error "date command not available"
        exit 1
    fi

}

# ---------- Get certificate list ----------
get_cert_names() {

    certbot certificates \
        | awk -F': ' '/Certificate Name:/ {print $2}'

}

# ---------- Process certificates ----------
process_certificates() {

    local now epoch_exp days_left threshold_epoch
    now=$(date +%s)
    threshold_epoch=$(( THRESHOLD_DAYS * 86400 ))

    for name in $(get_cert_names); do

        log_info "Checking certificate: $name"

        exp=$(certbot certificates --cert-name "$name" 2>/dev/null \
              | awk -F': ' '/Expiry Date:/ {print $2}' \
              | cut -d '(' -f1)

        if [[ -z "$exp" ]]; then
            log_warn "Could not read expiry for $name"
            continue
        fi

        epoch_exp=$(date -d "$exp" +%s)
        days_left=$(( (epoch_exp - now) / 86400 ))

        if (( epoch_exp <= now )); then
            log_warn "Certificate EXPIRED: $name"

            if [[ "$MODE" == "renew" ]]; then
                renew_cert "$name"
            fi

        elif (( epoch_exp - now <= threshold_epoch )); then
            log_warn "Certificate expiring soon ($days_left days): $name"

            if [[ "$MODE" == "renew" ]]; then
                renew_cert "$name"
            fi

        else
            log_ok "Certificate valid ($days_left days left): $name"
        fi

    done
}

# ---------- Renew certificate ----------
renew_cert() {

    local cert="$1"

    log_info "Renewing certificate: $cert"

    if certbot renew --cert-name "$cert"; then
        log_ok "Renew successful: $cert"
    else
        log_error "Renew failed: $cert"
    fi

}

# ---------- Main ----------
main() {

    parse_args "$@"

    log_info "Mode: $MODE"
    log_info "Threshold: $THRESHOLD_DAYS days"

    check_dependencies
    process_certificates

}

main "$@"