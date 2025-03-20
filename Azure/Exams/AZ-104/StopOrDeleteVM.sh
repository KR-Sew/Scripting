#!/bin/bash

# Exit immediately if a command fails
set -e

# Define parameters
action="$1"       # Action: "deallocate" or "delete"
rgName="$2"       # Azure resource group name
vmName="$3"       # VM name

# Validate input
if [[ -z "$action" || -z "$rgName" || -z "$vmName" ]]; then
    echo "Usage: $0 <deallocate|delete> <resource-group> <vm-name>"
    echo "Example to deallocate: $0 deallocate myResourceGroup myVM"
    echo "Example to delete: $0 delete myResourceGroup myVM"
    exit 1
fi

# Perform the selected action
case "$action" in
    deallocate)
        echo "Deallocating VM: $vmName in resource group: $rgName..."
        az vm deallocate --resource-group "$rgName" --name "$vmName"
        echo "VM successfully deallocated."
        ;;
    delete)
        # Confirm before deleting
        read -p "Are you sure you want to delete VM '$vmName'? This cannot be undone! (yes/no): " confirm
        if [[ "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            echo "Deleting VM: $vmName in resource group: $rgName..."
            az vm delete --resource-group "$rgName" --name "$vmName" --yes
            echo "VM successfully deleted."
        else
            echo "VM deletion cancelled."
        fi
        ;;
    *)
        echo "Invalid action: $action"
        echo "Valid actions: deallocate, delete"
        exit 1
        ;;
esac
