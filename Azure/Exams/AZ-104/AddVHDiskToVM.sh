#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define parameters
VM_NAME="$1"
DISK_NAME="$2"
DISK_SIZE="$3"
DISK_SKU="$4"

# Validate input
if [[ -z "$VM_NAME" || -z "$DISK_NAME" || -z "$DISK_SIZE" || -z "$DISK_SKU" ]]; then
    echo "Usage: $0 <vm-name> <disk-name> <size-gb> <sku>"
    exit 1
fi

# Attach the disk to the VM
az vm disk attach --vm-name="$VM_NAME" --name="$DISK_NAME" --size-gb="$DISK_SIZE" --sku="$DISK_SKU" --new
