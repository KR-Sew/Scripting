#!/usr/bin/env bash

# Create a Proxmox VE VM using recommended presets for:
#   linux      - Debian, Ubuntu, and other modern Linux distributions
#   windows    - Windows 10 and Windows Server
#   windows11  - Windows 11 with TPM 2.0
#
# The script creates the VM configuration and an empty system disk.
# It does not start the VM automatically unless --start is specified.

set -Eeuo pipefail

PROGRAM_NAME="$(basename "$0")"

VMID=""
VM_NAME=""
OS_TYPE=""
STORAGE=""
ISO=""
BRIDGE="vmbr0"

CORES=2
SOCKETS=1
MEMORY=4096
DISK_SIZE="32G"
VLAN_TAG=""
START_VM=0
ONBOOT=0

MACHINE="q35"
BIOS="ovmf"
CPU_TYPE="host"
SCSI_HW="virtio-scsi-single"
NETWORK_MODEL="virtio"
OSTYPE=""
EFI_STORAGE=""
TPM_STORAGE=""
VIRTIO_ISO=""

usage() {
    cat <<EOF
Usage:
  sudo ./${PROGRAM_NAME} [options]

Required options:
  --vmid ID               Proxmox VM ID
  --name NAME             VM name
  --os TYPE               linux, windows, or windows11
  --storage STORAGE       Storage for the VM disk
  --iso VOLUME            Installation ISO volume

Optional:
  --cores NUMBER          CPU cores; default: ${CORES}
  --sockets NUMBER        CPU sockets; default: ${SOCKETS}
  --memory MB             RAM in MB; default: ${MEMORY}
  --disk-size SIZE        System disk size; default: ${DISK_SIZE}
  --bridge BRIDGE         Network bridge; default: ${BRIDGE}
  --vlan TAG              VLAN tag
  --cpu TYPE              CPU type; default: ${CPU_TYPE}
  --machine TYPE          q35 or i440fx; default: ${MACHINE}
  --bios TYPE             ovmf or seabios; default: ${BIOS}
  --efi-storage STORAGE   EFI disk storage; defaults to --storage
  --tpm-storage STORAGE   TPM storage; defaults to --storage
  --virtio-iso VOLUME     Windows VirtIO driver ISO
  --onboot                Start VM when Proxmox boots
  --start                 Start VM after creation
  --help                  Show this help

Examples:

  Debian/Ubuntu:
    sudo ./${PROGRAM_NAME} \\
      --vmid 192 \\
      --name debian12-srv \\
      --os linux \\
      --storage local-zfs \\
      --iso local:iso/debian-12.11.0-amd64-netinst.iso \\
      --cores 4 \\
      --memory 8192 \\
      --disk-size 64G

  Windows Server:
    sudo ./${PROGRAM_NAME} \\
      --vmid 193 \\
      --name windows-server \\
      --os windows \\
      --storage local-zfs \\
      --iso local:iso/windows-server.iso \\
      --virtio-iso local:iso/virtio-win.iso \\
      --cores 4 \\
      --memory 8192 \\
      --disk-size 100G

  Windows 11:
    sudo ./${PROGRAM_NAME} \\
      --vmid 194 \\
      --name windows11 \\
      --os windows11 \\
      --storage local-zfs \\
      --iso local:iso/windows11.iso \\
      --virtio-iso local:iso/virtio-win.iso \\
      --cores 4 \\
      --memory 8192 \\
      --disk-size 100G
EOF
}

error() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

validate_integer() {
    local value="$1"
    local description="$2"

    [[ "$value" =~ ^[0-9]+$ ]] ||
        error "${description} must be a positive integer: ${value}"

    (( value > 0 )) ||
        error "${description} must be greater than zero"
}

cleanup_failed_vm() {
    local exit_code=$?

    if (( exit_code != 0 )); then
        printf '\nVM creation failed.\n' >&2

        if [[ -n "$VMID" ]] && qm status "$VMID" >/dev/null 2>&1; then
            printf 'Removing partially created VM %s...\n' "$VMID" >&2

            qm stop "$VMID" --skiplock 1 >/dev/null 2>&1 || true
            qm destroy "$VMID" --purge 1 --destroy-unreferenced-disks 1 \
                >/dev/null 2>&1 || true
        fi
    fi

    exit "$exit_code"
}

trap cleanup_failed_vm ERR

while (( $# > 0 )); do
    case "$1" in
        --vmid)
            VMID="${2:?Missing value for --vmid}"
            shift 2
            ;;
        --name)
            VM_NAME="${2:?Missing value for --name}"
            shift 2
            ;;
        --os)
            OS_TYPE="${2:?Missing value for --os}"
            shift 2
            ;;
        --storage)
            STORAGE="${2:?Missing value for --storage}"
            shift 2
            ;;
        --iso)
            ISO="${2:?Missing value for --iso}"
            shift 2
            ;;
        --cores)
            CORES="${2:?Missing value for --cores}"
            shift 2
            ;;
        --sockets)
            SOCKETS="${2:?Missing value for --sockets}"
            shift 2
            ;;
        --memory)
            MEMORY="${2:?Missing value for --memory}"
            shift 2
            ;;
        --disk-size)
            DISK_SIZE="${2:?Missing value for --disk-size}"
            shift 2
            ;;
        --bridge)
            BRIDGE="${2:?Missing value for --bridge}"
            shift 2
            ;;
        --vlan)
            VLAN_TAG="${2:?Missing value for --vlan}"
            shift 2
            ;;
        --cpu)
            CPU_TYPE="${2:?Missing value for --cpu}"
            shift 2
            ;;
        --machine)
            MACHINE="${2:?Missing value for --machine}"
            shift 2
            ;;
        --bios)
            BIOS="${2:?Missing value for --bios}"
            shift 2
            ;;
        --efi-storage)
            EFI_STORAGE="${2:?Missing value for --efi-storage}"
            shift 2
            ;;
        --tpm-storage)
            TPM_STORAGE="${2:?Missing value for --tpm-storage}"
            shift 2
            ;;
        --virtio-iso)
            VIRTIO_ISO="${2:?Missing value for --virtio-iso}"
            shift 2
            ;;
        --onboot)
            ONBOOT=1
            shift
            ;;
        --start)
            START_VM=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            ;;
    esac
done

[[ $EUID -eq 0 ]] ||
    error "Run this script as root or with sudo"

command_exists qm ||
    error "The qm command was not found. Run this on a Proxmox VE node."

command_exists pvesm ||
    error "The pvesm command was not found."

[[ -n "$VMID" ]]     || error "--vmid is required"
[[ -n "$VM_NAME" ]]  || error "--name is required"
[[ -n "$OS_TYPE" ]]  || error "--os is required"
[[ -n "$STORAGE" ]]  || error "--storage is required"
[[ -n "$ISO" ]]      || error "--iso is required"

validate_integer "$VMID" "VM ID"
validate_integer "$CORES" "Core count"
validate_integer "$SOCKETS" "Socket count"
validate_integer "$MEMORY" "Memory"

[[ "$DISK_SIZE" =~ ^[0-9]+([KMGT])?$ ]] ||
    error "Invalid disk size: ${DISK_SIZE}. Example: 32G"

case "$MACHINE" in
    q35|i440fx|pc|pc-i440fx-*)
        ;;
    *)
        error "Unsupported machine value: ${MACHINE}"
        ;;
esac

case "$BIOS" in
    ovmf|seabios)
        ;;
    *)
        error "BIOS must be either ovmf or seabios"
        ;;
esac

case "$OS_TYPE" in
    linux)
        OSTYPE="l26"
        ;;
    windows)
        # win10 is appropriate for modern Windows guests in Proxmox.
        OSTYPE="win10"
        ;;
    windows11)
        OSTYPE="win11"
        ;;
    *)
        error "--os must be linux, windows, or windows11"
        ;;
esac

EFI_STORAGE="${EFI_STORAGE:-$STORAGE}"
TPM_STORAGE="${TPM_STORAGE:-$STORAGE}"

if qm status "$VMID" >/dev/null 2>&1; then
    error "VM ID ${VMID} already exists"
fi

if ! pvesm status --storage "$STORAGE" >/dev/null 2>&1; then
    error "Storage '${STORAGE}' does not exist or is unavailable"
fi

if [[ "$BIOS" == "ovmf" ]] &&
   ! pvesm status --storage "$EFI_STORAGE" >/dev/null 2>&1; then
    error "EFI storage '${EFI_STORAGE}' does not exist or is unavailable"
fi

if [[ "$OS_TYPE" == "windows11" ]] &&
   ! pvesm status --storage "$TPM_STORAGE" >/dev/null 2>&1; then
    error "TPM storage '${TPM_STORAGE}' does not exist or is unavailable"
fi

NET_CONFIG="${NETWORK_MODEL},bridge=${BRIDGE},firewall=1"

if [[ -n "$VLAN_TAG" ]]; then
    validate_integer "$VLAN_TAG" "VLAN tag"

    if (( VLAN_TAG < 1 || VLAN_TAG > 4094 )); then
        error "VLAN tag must be between 1 and 4094"
    fi

    NET_CONFIG+=",tag=${VLAN_TAG}"
fi

printf '%s\n' \
    "Creating VM:" \
    "  VM ID:       ${VMID}" \
    "  Name:        ${VM_NAME}" \
    "  OS preset:   ${OS_TYPE}" \
    "  Machine:     ${MACHINE}" \
    "  Firmware:    ${BIOS}" \
    "  CPU:         ${SOCKETS} socket(s), ${CORES} core(s)" \
    "  Memory:      ${MEMORY} MB" \
    "  Disk:        ${STORAGE}:${DISK_SIZE}" \
    "  ISO:         ${ISO}" \
    "  Network:     ${NET_CONFIG}"

qm create "$VMID" \
    --name "$VM_NAME" \
    --description "Created by ${PROGRAM_NAME}" \
    --ostype "$OSTYPE" \
    --machine "$MACHINE" \
    --bios "$BIOS" \
    --cpu "$CPU_TYPE" \
    --sockets "$SOCKETS" \
    --cores "$CORES" \
    --memory "$MEMORY" \
    --balloon 0 \
    --numa 0 \
    --scsihw "$SCSI_HW" \
    --net0 "$NET_CONFIG" \
    --agent enabled=1,fstrim_cloned_disks=1 \
    --onboot "$ONBOOT" \
    --startup order=1,up=30,down=60 \
    --boot order=scsi0\;ide2

# Allocate the operating-system disk.
qm set "$VMID" \
    --scsi0 "${STORAGE}:${DISK_SIZE},discard=on,iothread=1,ssd=1"

# Attach installation media.
qm set "$VMID" --ide2 "${ISO},media=cdrom"

# Create an EFI variables disk for UEFI guests.
if [[ "$BIOS" == "ovmf" ]]; then
    EFI_OPTIONS="${EFI_STORAGE}:1,efitype=4m,pre-enrolled-keys=1"

    # Windows 11 normally uses Secure Boot-compatible pre-enrolled keys.
    # Linux can also boot with these keys; Secure Boot can be disabled later.
    qm set "$VMID" --efidisk0 "$EFI_OPTIONS"
fi

# Add TPM 2.0 for Windows 11.
if [[ "$OS_TYPE" == "windows11" ]]; then
    qm set "$VMID" \
        --tpmstate0 "${TPM_STORAGE}:1,version=v2.0"
fi

# Attach the VirtIO Windows driver ISO as a second CD-ROM.
if [[ -n "$VIRTIO_ISO" ]]; then
    qm set "$VMID" --ide0 "${VIRTIO_ISO},media=cdrom"
fi

printf '\nVM %s was created successfully.\n\n' "$VMID"
qm config "$VMID"

if (( START_VM == 1 )); then
    printf '\nStarting VM %s...\n' "$VMID"
    qm start "$VMID"
else
    printf '\nStart it with:\n  qm start %s\n' "$VMID"
fi

trap - ERR