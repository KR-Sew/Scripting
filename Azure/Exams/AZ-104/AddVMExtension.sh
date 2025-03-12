# Add a script for Vm installation process

az vm extension set --vm-name support-web-vm01 --name customScript --publisher Microsoft.Azure.Extensions --settings '{"fileUris":["https://raw.githubusercontent.com/MicrosoftDocs/mslearn-add-and-size-disks-in-azure-virtual-machines/master/add-data-disk.sh"]}' --protected-settings '{"commandToExecute": "./add-data-disk.sh"}'
