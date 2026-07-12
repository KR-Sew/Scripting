#!/usr/bin/env bash

# ==============================================================================
# Rust installer and updater for Debian / Ubuntu
#
# Installs and manages the latest stable Rust toolchain using rustup.
#
# Usage:
#   sudo bash ./assets/install_rust.sh
#
# Optional arguments:
#   --check       Check installed and available versions without updating
#   --force       Reinstall/update even when the installed version is current
#   --uninstall   Remove the system-wide rustup installation
#   --help        Display help
#
# Installation paths:
#   Rustup data:  /opt/rustup
#   Cargo data:   /opt/cargo
#   Commands:     /usr/local/bin/{rustup,rustc,cargo,...}
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

readonly SCRIPT_NAME="${0##*/}"

readonly RUSTUP_HOME="/opt/rustup"
readonly CARGO_HOME="/opt/cargo"
readonly BIN_DIR="/usr/local/bin"

readonly RUSTUP_INIT_URL="https://sh.rustup.rs"
readonly TOOLCHAIN="stable"
readonly PROFILE="minimal"

CHECK_ONLY=false
FORCE_UPDATE=false
UNINSTALL=false

export RUSTUP_HOME
export CARGO_HOME
export PATH="${CARGO_HOME}/bin:${BIN_DIR}:${PATH}"

# ------------------------------------------------------------------------------
# Colours
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[0;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly RESET='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly RESET=''
fi

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

print_info() {
    printf "${BLUE}[INFO]${RESET} %s\n" "$*"
}

print_success() {
    printf "${GREEN}[OK]${RESET} %s\n" "$*"
}

print_warning() {
    printf "${YELLOW}[WARNING]${RESET} %s\n" "$*" >&2
}

print_error() {
    printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
}

print_step() {
    printf "\n${CYAN}${BOLD}==> %s${RESET}\n" "$*"
}

# ------------------------------------------------------------------------------
# Error handling
# ------------------------------------------------------------------------------

on_error() {
    local exit_code=$?
    local line_number="${BASH_LINENO[0]:-unknown}"

    print_error "The script failed on line ${line_number} with exit code ${exit_code}."
    exit "$exit_code"
}

trap on_error ERR

cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

show_help() {
    cat <<EOF
Usage:
  sudo bash ${SCRIPT_NAME} [OPTION]

Options:
  --check       Check installed Rust and stable-channel versions
  --force       Force rustup and toolchain update
  --uninstall   Remove the system-wide Rust installation
  -h, --help    Display this help

Examples:
  sudo bash ${SCRIPT_NAME}
  sudo bash ${SCRIPT_NAME} --check
  sudo bash ${SCRIPT_NAME} --force
  sudo bash ${SCRIPT_NAME} --uninstall
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check)
                CHECK_ONLY=true
                ;;
            --force)
                FORCE_UPDATE=true
                ;;
            --uninstall)
                UNINSTALL=true
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown argument: $1"
                show_help
                exit 2
                ;;
        esac

        shift
    done
}

# ------------------------------------------------------------------------------
# System checks
# ------------------------------------------------------------------------------

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        print_error "This script must be run as root."
        print_info "Run:"
        printf '  sudo bash %q\n' "$0"
        exit 1
    fi
}

detect_operating_system() {
    if [[ ! -r /etc/os-release ]]; then
        print_error "Cannot detect the operating system: /etc/os-release is missing."
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    DISTRO_ID="${ID:-unknown}"
    DISTRO_NAME="${PRETTY_NAME:-${NAME:-unknown}}"

    case "$DISTRO_ID" in
        debian|ubuntu)
            print_success "Detected operating system: ${DISTRO_NAME}"
            ;;
        *)
            print_error "Unsupported operating system: ${DISTRO_NAME}"
            print_info "This script supports Debian and Ubuntu."
            exit 1
            ;;
    esac
}

check_architecture() {
    local architecture

    architecture="$(uname -m)"

    case "$architecture" in
        x86_64|amd64|aarch64|arm64|armv7l|i686)
            print_success "Supported architecture detected: ${architecture}"
            ;;
        *)
            print_warning "Architecture '${architecture}' has not been tested by this script."
            ;;
    esac
}

# ------------------------------------------------------------------------------
# Package dependencies
# ------------------------------------------------------------------------------

install_dependencies() {
    print_step "Checking required system packages"

    local packages=(
        ca-certificates
        curl
        gcc
        libc6-dev
        pkg-config
    )

    local missing_packages=()
    local package

    for package in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
            grep -q '^install ok installed$'; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        print_success "All required system packages are already installed."
        return
    fi

    print_info "Installing missing packages:"
    printf '  %s\n' "${missing_packages[@]}"

    apt-get update
    DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends "${missing_packages[@]}"

    print_success "Required system packages installed."
}

# ------------------------------------------------------------------------------
# Rust version helpers
# ------------------------------------------------------------------------------

rustup_is_installed() {
    [[ -x "${CARGO_HOME}/bin/rustup" ]]
}

rust_is_installed() {
    [[ -x "${CARGO_HOME}/bin/rustc" ]] &&
        [[ -x "${CARGO_HOME}/bin/cargo" ]]
}

get_installed_rust_version() {
    if ! rust_is_installed; then
        return 1
    fi

    "${CARGO_HOME}/bin/rustc" --version |
        awk '{print $2}'
}

get_active_toolchain() {
    if ! rustup_is_installed; then
        return 1
    fi

    "${CARGO_HOME}/bin/rustup" show active-toolchain 2>/dev/null |
        awk '{print $1}'
}

get_available_stable_version() {
    local update_output
    local available_version

    # "rustup check" checks for toolchain updates without installing them.
    update_output="$(
        "${CARGO_HOME}/bin/rustup" check 2>/dev/null || true
    )"

    available_version="$(
        awk '
            /^stable-/ {
                for (i = 1; i <= NF; i++) {
                    if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+/) {
                        gsub(/[(),]/, "", $i)
                        print $i
                        exit
                    }
                }
            }
        ' <<< "$update_output"
    )"

    if [[ -n "$available_version" ]]; then
        printf '%s\n' "$available_version"
        return 0
    fi

    # If rustup reports that stable is up to date, obtain the current
    # stable version from the installed stable toolchain.
    "${CARGO_HOME}/bin/rustup" run stable rustc --version 2>/dev/null |
        awk '{print $2}'
}

version_is_newer() {
    local installed_version="$1"
    local available_version="$2"

    [[ "$installed_version" != "$available_version" ]] &&
        [[ "$(printf '%s\n%s\n' \
            "$installed_version" \
            "$available_version" |
            sort -V |
            tail -n 1)" == "$available_version" ]]
}

# ------------------------------------------------------------------------------
# Command links and environment
# ------------------------------------------------------------------------------

create_command_links() {
    print_step "Creating system-wide Rust command wrappers"

    local command
    local commands=(
        cargo
        cargo-clippy
        cargo-fmt
        clippy-driver
        rustc
        rustdoc
        rustfmt
        rustup
    )

    mkdir -p "$BIN_DIR"

    for command in "${commands[@]}"; do
        if [[ -e "${CARGO_HOME}/bin/${command}" ]]; then
            rm -f "${BIN_DIR}/${command}"

            cat > "${BIN_DIR}/${command}" <<EOF
#!/bin/sh

export RUSTUP_HOME="${RUSTUP_HOME}"
export CARGO_HOME="${CARGO_HOME}"

exec "${CARGO_HOME}/bin/${command}" "\$@"
EOF

            chmod 0755 "${BIN_DIR}/${command}"
        fi
    done

    print_success "Rust command wrappers were created in ${BIN_DIR}."
}

create_environment_file() { print_step "Creating system-wide Rust environment"

    cat > /etc/profile.d/rust.sh <<EOF
# System-wide Rust environment managed by ${SCRIPT_NAME}
export RUSTUP_HOME="${RUSTUP_HOME}"
export CARGO_HOME="${CARGO_HOME}"
export PATH="\${CARGO_HOME}/bin:\${PATH}"
EOF

    chmod 0644 /etc/profile.d/rust.sh

    print_success "Created /etc/profile.d/rust.sh."
}

# ------------------------------------------------------------------------------
# Installation and update
# ------------------------------------------------------------------------------

install_rust() {
    print_step "Installing Rust ${TOOLCHAIN} toolchain"

    TEMP_DIR="$(mktemp -d)"
    local installer="${TEMP_DIR}/rustup-init.sh"

    curl \
        --proto '=https' \
        --tlsv1.2 \
        --fail \
        --silent \
        --show-error \
        --location \
        "$RUSTUP_INIT_URL" \
        --output "$installer"

    if [[ ! -s "$installer" ]]; then
        print_error "The downloaded Rust installer is empty."
        return 1
    fi

    print_info "Downloaded the Rust installer."

    /bin/sh "$installer" \
        -y \
        --no-modify-path \
        --default-toolchain "$TOOLCHAIN" \
        --profile "$PROFILE"

    create_command_links
    create_environment_file

    print_success "Rust installation completed."
}

update_rustup() {
    print_step "Checking rustup for updates"

    local old_version
    local new_version

    old_version="$("${CARGO_HOME}/bin/rustup" --version | awk '{print $2}')"

    print_info "Installed rustup version: ${old_version}"

    # A rustup build may disable self-update. In that case, updating the
    # toolchains still works and no toolchain data is lost.
    if "${CARGO_HOME}/bin/rustup" self update; then
        new_version="$("${CARGO_HOME}/bin/rustup" --version | awk '{print $2}')"

        if [[ "$old_version" == "$new_version" ]]; then
            print_success "rustup is already current: ${new_version}"
        else
            print_success "rustup updated: ${old_version} -> ${new_version}"
        fi
    else
        print_warning "rustup could not update itself automatically."
        print_warning "The Rust toolchain update will still be attempted."
    fi
}

update_rust_toolchain() {
    print_step "Checking the Rust ${TOOLCHAIN} toolchain"

    local installed_version
    local available_version
    local active_toolchain

    installed_version="$(get_installed_rust_version)"
    active_toolchain="$(get_active_toolchain || printf 'unknown')"

    print_info "Installed Rust version: ${installed_version}"
    print_info "Active toolchain: ${active_toolchain}"

    available_version="$(get_available_stable_version || true)"

    if [[ -n "$available_version" ]]; then
        print_info "Available stable version: ${available_version}"
    else
        print_warning "Could not determine the available stable Rust version."
    fi

    if "$CHECK_ONLY"; then
        if [[ -n "$available_version" ]] &&
            version_is_newer "$installed_version" "$available_version"; then
            print_warning \
                "A newer Rust version is available: ${available_version}"
            return 10
        fi

        print_success "No Rust update is required."
        return
    fi

    if [[ -n "$available_version" ]] &&
        [[ "$installed_version" == "$available_version" ]] &&
        ! "$FORCE_UPDATE"; then
        print_success "Rust is already up to date: ${installed_version}"
        return
    fi

    if "$FORCE_UPDATE"; then
        print_info "A forced toolchain update was requested."
    elif [[ -n "$available_version" ]]; then
        print_info \
            "Updating Rust: ${installed_version} -> ${available_version}"
    else
        print_info "Running the stable toolchain update."
    fi

    "${CARGO_HOME}/bin/rustup" update "$TOOLCHAIN"
    "${CARGO_HOME}/bin/rustup" default "$TOOLCHAIN"

    create_command_links

    local updated_version
    updated_version="$(get_installed_rust_version)"

    if [[ "$installed_version" == "$updated_version" ]]; then
        print_success "Rust is already current: ${updated_version}"
    else
        print_success \
            "Rust updated successfully: ${installed_version} -> ${updated_version}"
    fi
}

verify_installation() {
    print_step "Verifying the Rust installation"

    local required_commands=(
        rustup
        rustc
        cargo
    )

    local command

    for command in "${required_commands[@]}"; do
        if ! command -v "$command" >/dev/null 2>&1; then
            print_error "Required command is unavailable: ${command}"
            exit 1
        fi
    done

    print_success "$(rustup --version)"
    print_success "$(rustc --version)"
    print_success "$(cargo --version)"
}

# ------------------------------------------------------------------------------
# Removal
# ------------------------------------------------------------------------------

uninstall_rust() {
    print_step "Removing the system-wide Rust installation"

    if rustup_is_installed; then
        # Remove toolchains through rustup first. Failure is nonfatal because
        # the installation directories are removed immediately afterwards.
        "${CARGO_HOME}/bin/rustup" self uninstall -y || true
    fi

    rm -rf "$RUSTUP_HOME" "$CARGO_HOME"
    rm -f /etc/profile.d/rust.sh

    local command
    local commands=(
        cargo
        cargo-clippy
        cargo-fmt
        clippy-driver
        rustc
        rustdoc
        rustfmt
        rustup
    )

    for command in "${commands[@]}"; do
        if [[ -L "${BIN_DIR}/${command}" ]]; then
            rm -f "${BIN_DIR}/${command}"
        fi
    done

    print_success "Rust has been removed."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    parse_arguments "$@"

    printf "${BOLD}Rust installer and updater${RESET}\n"

    require_root
    detect_operating_system
    check_architecture

    if "$UNINSTALL"; then
        uninstall_rust
        exit 0
    fi

    install_dependencies

    if rustup_is_installed && rust_is_installed; then
        print_success "An existing rustup-managed Rust installation was found."

        update_rustup
        update_rust_toolchain
    else
        if command -v rustc >/dev/null 2>&1 ||
            command -v cargo >/dev/null 2>&1; then
            print_warning \
                "A non-rustup Rust installation was found and will not be removed."
            print_warning \
                "The rustup-managed toolchain will take precedence in ${BIN_DIR}."
        else
            print_info "Rust is not installed."
        fi

        if "$CHECK_ONLY"; then
            print_warning "Rust is not installed."
            exit 10
        fi

        install_rust
    fi

    verify_installation

    print_step "Rust setup completed successfully"
}

main "$@"