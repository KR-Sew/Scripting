
param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$currentAdapterName,

    [Parameter(Mandatory = $true)]
    [string]$newAdapterName
)

# Ensure the VM is running
$vm = Get-VM -Name $VMName -ErrorAction Stop
if ($vm.State -ne 'Running') {
    Write-Error "VM '$VMName' is not running. Please start it before running this script."
    exit 1
}
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