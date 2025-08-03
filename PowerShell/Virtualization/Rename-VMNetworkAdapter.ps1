$vmName = "Windows-Dc01"
$currentAdapterName = "Network Adapter 1"  # Replace with actual adapter name
$newAdapterName = "Eth01"

try {
    $adapter = Get-VMNetworkAdapter -VMName $vmName -Name $currentAdapterName -ErrorAction Stop
    if ($adapter) {
        $adapter | Rename-VMNetworkAdapter -NewName $newAdapterName -Passthru
        Write-Output "Successfully renamed network adapter to $newAdapterName for VM $vmName."
    } else {
        Write-Error "No network adapter found with name $currentAdapterName for VM $vmName."
    }
} catch {
    Write-Error "Failed to rename network adapter. Error: $($_.Exception.Message)"
}