#!/bin/bash

# Check if the required parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <resource-group> <vm-name>"
    exit 1
fi

# Assign parameters to variables
RGROUP="$1"
VMNAME="$2"

# Get admin username
ADMIN_NAME=$(az vm show --resource-group "$RGROUP" --name "$VMNAME" --query "osProfile.adminUsername" --output tsv)
echo "Admin Username: $ADMIN_NAME"

# Get VM size
VM_SIZE=$(az vm show --resource-group "$RGROUP" --name "$VMNAME" --query "hardwareProfile.vmSize" --output tsv)
echo "VM Size: $VM_SIZE"

# Get network interfaces (JSON format)
NIC_IDS_JSON=$(az vm show --resource-group "$RGROUP" --name "$VMNAME" --query "networkProfile.networkInterfaces[].id" --output json)
echo "Network Interfaces (JSON): $NIC_IDS_JSON"

# Get network interfaces (TSV format)
NIC_IDS_TSV=$(az vm show --resource-group "$RGROUP" --name "$VMNAME" --query "networkProfile.networkInterfaces[].id" --output tsv)
echo "Network Interfaces (TSV):"
echo "$NIC_IDS_TSV"
