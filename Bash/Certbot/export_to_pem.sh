#!/usr/bin/env bash

# ---------- Colors ----------
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }

# ---------- Function ----------
extract_pfx() {

    local pfx="$1"
    local out_dir="$2"

    if [[ -z "$pfx" || -z "$out_dir" ]]; then
        log_error "Usage: extract_pfx <file.pfx> <output_dir>"
        exit 1
    fi

    if [[ ! -f "$pfx" ]]; then
        log_error "File not found: $pfx"
        exit 1
    fi

    mkdir -p "$out_dir"

    log_info "Extracting PFX: $pfx"

    # Private key
    openssl pkcs12 -in "$pfx" -nocerts -nodes \
        -out "$out_dir/privkey.pem"

    # Full chain
    openssl pkcs12 -in "$pfx" -nokeys \
        -out "$out_dir/fullchain.pem"

    # Clean key
    sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' \
        "$out_dir/privkey.pem" > "$out_dir/privkey.clean.pem"

    # Clean certs
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
        "$out_dir/fullchain.pem" > "$out_dir/fullchain.clean.pem"

    chmod 600 "$out_dir/privkey.clean.pem"

    log_ok "Extraction completed:"
    log_ok "  Key:  $out_dir/privkey.clean.pem"
    log_ok "  Cert: $out_dir/fullchain.clean.pem"
}

# ---------- Entry point ----------
main() {
    extract_pfx "$@"
}

main "$@"