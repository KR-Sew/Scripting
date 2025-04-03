param (
    [Parameter(Mandatory = $true)]
    [string]$VMName  # Name of the existing VM
)

# Check if VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}

# Get the VM network adapter
$adapter = Get-VMNetworkAdapter -VMName $VMName -ErrorAction SilentlyContinue
if (-not $adapter) {
    Write-Host "❌ Error: No network adapter found on VM '$VMName'!" -ForegroundColor Red
    exit 1
}

$adapterName = $adapter.Name
$switchName = $adapter.SwitchName

if (-not $switchName) {
    Write-Host "❌ Error: The network adapter is not connected to any switch!" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Found network adapter: $adapterName (Connected to: $switchName)"

# Disconnect the adapter
Write-Host "⏳ Disconnecting network adapter..."
Disconnect-VMNetworkAdapter -VMName $VMName -Name $adapterName
Start-Sleep -Seconds 2

# Reconnect the adapter using the same switch
Write-Host "✅ Reconnecting network adapter to '$switchName'..."
Connect-VMNetworkAdapter -VMName $VMName -Name $adapterName -SwitchName $switchName

Write-Host "🚀 Network adapter '$adapterName' for VM '$VMName' has been restarted successfully!" -ForegroundColor Green
