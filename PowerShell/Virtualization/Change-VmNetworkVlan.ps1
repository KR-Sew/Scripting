# Define the name of the virtual machine and the new VLAN ID
$vmName = "YourVMName"  # Replace with the name of your virtual machine
$newVlanId = 100        # Replace with the desired VLAN ID

# Get the virtual machine
$vm = Get-VM -Name $vmName

if (-not $vm) {
    Write-Host "Virtual machine '$vmName' not found."
    exit
}

# Get the network adapter of the virtual machine
$networkAdapter = Get-VMNetworkAdapter -VM $vm

if (-not $networkAdapter) {
    Write-Host "No network adapter found for virtual machine '$vmName'."
    exit
}

# Change the VLAN ID
try {
    Set-VMNetworkAdapterVlan -VMNetworkAdapter $networkAdapter -Access -VlanId $newVlanId
    Write-Host "VLAN ID for virtual machine '$vmName' has been changed to $newVlanId."
} catch {
    Write-Host "An error occurred: $_"
}
