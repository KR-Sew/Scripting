# Get admin name of the vm
az vm show --resource-group "[sandbox resource group name]" --name SampleVM --query "osProfile.adminUsername"

# Get the size of the vm
az vm show --resource-group "[sandbox resource group name]" --name SampleVM --query hardwareProfile.vmSize

# Get all netrwork interfaces of the vm
az vm show --resource-group "[sandbox resource group name]" --name SampleVM --query "networkProfile.networkInterfaces[].id"

# The same query as above but with -tsv key parameter
az vm show --resource-group "[sandbox resource group name]" --name SampleVM --query "networkProfile.networkInterfaces[].id" -o tsv