#!/bin/bash
# Store the VM id
vmID=$(az vm show --resource-group $rgName --name $vmName --query id --output tsv)
echo $vmID

# Store the public IP address
publicIP=$(az vm list-ip-addresses --resource-group $rgName --name $vmName --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)
echo $publicIP