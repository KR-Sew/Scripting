#!/bin/bash
# details of all VMs in a specified resource group
az vm show --show-details --ids $(az vm list --resource-group $rgName --query "[].id" -o tsv)

# list of all VMs created in the last 7 days
createDate=$(date +%F -d "-7days")
az vm list --resource-group $rgName --query "[?timeCreated >='$createDate'].{Name:name, admin:osProfile.adminUsername, DiskSize:storageProfile.osDisk.diskSizeGb}" --output table

# list all VMs whose disks are of a certain type
# first get a list of the disk types or organization is using
az vm list --resource-group $rgName --query "[].{Name:name, osDiskSize:storageProfile.osDisk.diskSizeGb, managedDiskTypes:storageProfile.osDisk.managedDisk.storageAccountType}" --output table

diskType="Premium_LRS"
az vm list --resource-group $rgName --query "[?storageProfile.osDisk.managedDisk.storageAccountType =='$diskType'].{Name:name, admin:osProfile.adminUsername, osDiskSize:storageProfile.osDisk.diskSizeGb, CreatedOn:timeCreated, vmID:id}" --output table