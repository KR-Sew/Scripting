param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$AdapterName
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Get the network adapter
$vmAdapter = Get-VMNetworkAdapter -VMName $VMName -Name $AdapterName -ErrorAction SilentlyContinue
if (-not $vmAdapter) {
    Write-Host "Network adapter '$AdapterName' not found on VM '$VMName'." -ForegroundColor Yellow
    exit 0
}

# Remove the network adapter
try {
    Remove-VMNetworkAdapter -VMName $VMName -Name $AdapterName -Confirm:$false
    Write-Host "Network adapter '$AdapterName' removed from VM '$VMName'." -ForegroundColor Green
} catch {
    Write-Host "Failed to remove network adapter: $_" -ForegroundColor Red
}
