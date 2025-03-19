#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define parameters
R_GROUP="$1"
VM_NAME="$2"
SIZE="$3"

# Validate input
if [[ -z "$R_GROUP" || -z "$VM_NAME" || -z "$SIZE" ]]; then
    echo "Usage: $0 <resource-group> <vm-name> <size>"
    exit 1
fi

# Resize option of the VM
az vm resize --resource-group="$R_GROUP" --name="$VM_NAME" --size="$SIZE"