# Get all virtual machines
$vms = Get-VM

# Check if there are any VMs
if ($vms.Count -eq 0) {
    Write-Host "No virtual machines found."
    exit
}

# Loop through each VM and get the associated virtual switch
foreach ($vm in $vms) {
    # Get the network adapter for the VM
    $networkAdapters = Get-VMNetworkAdapter -VM $vm

    # Display VM name and associated virtual switch
    foreach ($adapter in $networkAdapters) {
        $virtualSwitchName = $adapter.SwitchName
        Write-Host "VM Name: $($vm.Name) - Virtual Switch: $virtualSwitchName"
    }
}
