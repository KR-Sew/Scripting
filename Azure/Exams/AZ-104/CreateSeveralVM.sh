#!/bin/bash
    
# Assign parameters to variables
vmCount=$1
adminUserPrefix=$2
shift 2
images=("$@")
    
# Loop 
for i in $(seq 1 $vmCount)
do
    let "randomIdentifier=$RANDOM*$RANDOM"
    resourceGroupName="msdocs-rg-$randomIdentifier"
    location="westus"
    adminUserName="msdocs-$randomIdentifier"
    vmName="msdocs-vm-$randomIdentifier"
    vmImage=${images[$((i-1)) % ${#images[@]}]}

echo "Creating VM $vmName on $mvImage with admin $adminUserName in resource group $resourceGroupName"

# create the resource group
    az group create --name $resourceGroupName --location $location

# create the VM
    az vm create --resource-group $resourceGroupName --location $location --admin-username $adminUserName --name $vmName --image $vmImage --generate-ssh-keys

done