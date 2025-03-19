#!/bin/bash

# Define parameters
R_GROUP="$1"
VM_NAME="$2"

# Validate input
if [[ -z "$R_GROUP" || -z "$VM_NAME" ]]; then
    echo "Usage: $0 <resource-group> <vm-name>"
    exit 1
fi

# List resizable option of the VM
az vm list-vm-resize-options --resource-group "$R_GROUP" --name "$VM_NAME" --output table
