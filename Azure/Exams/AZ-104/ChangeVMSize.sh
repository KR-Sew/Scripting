az vm list-vm-resize-options --resource-group "[sandbox resource group name]" --name SampleVM --output table

az vm resize --resource-group "[sandbox resource group name]" --name SampleVM --size Standard_D2s_v3