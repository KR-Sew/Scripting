#!/bin/bash

# Check if both parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <vm_name> <resource_group>"
    exit 1
fi

# Assign parameters to variables
VM_NAME=$1
RESOURCE_GROUP=$2

# Stop the Azure VM
az vm stop --name "$VM_NAME" --resource-group "$RESOURCE_GROUP"

# Check the exit status of the last command
if [ $? -eq 0 ]; then
    echo "Virtual machine '$VM_NAME' in resource group '$RESOURCE_GROUP' has been stopped successfully."
else
    echo "Failed to stop the virtual machine. Please check the VM name and resource group."
fi
