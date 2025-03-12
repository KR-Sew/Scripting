#!/bin/bash

# Get the single resource group name created by the sandbox.
rgName=$(az group list --query "[].{Name:name}" --output tsv)
echo $rgName

# Create additional variables with values of your choice.
vmName="msdocs-vm-01"
vmLocation="westeurope"
vmImage="Ubuntu2204"
vmAdminUserName="myAzureUserName"

# Create the VM
az vm create --resource-group $rgName --name $vmName --location $vmLocation --image $vmImage --public-ip-sku Standard --admin-username $vmAdminUserName --generate-ssh-keys