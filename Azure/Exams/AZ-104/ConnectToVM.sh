#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define parameters
keyPath="$1"
rgName="$2"
vmName="$3"
vmAdminUserName="$4"

# Validate input
if [[ -z "$keyPath" || -z "$rgName" || -z "$vmName" || -z "$vmAdminUserName" ]]; then
    echo "Usage: $0 <key-path> <resource-group> <vm-name> <admin-name>"
    echo "Example: $0 ~/.ssh/id_rsa myResourceGroup myVM adminUser"
    exit 1
fi

# Connect to the VM using Azure CLI
az ssh vm --private-key-file="$keyPath" --resource-group=$rgName --name=$vmName --local-user=$vmAdminUserName
