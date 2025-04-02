param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,       # Name of the existing VM

    [Parameter(Mandatory = $true)]
    [string]$VmSwitch      # New virtual switch name to connect to
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}

# Check if the specified switch exists
if (-not (Get-VMSwitch -Name $VmSwitch -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Virtual switch '$VmSwitch' does not exist!" -ForegroundColor Red
    exit 1
}

# Get the VM network adapter
$adapter = Get-VMNetworkAdapter -VMName $VMName -ErrorAction SilentlyContinue
if (-not $adapter) {
    Write-Host "Error: No network adapter found on VM '$VMName'!" -ForegroundColor Red
    exit 1
}

# Disconnect the network adapter
Write-Host "Disconnecting network adapter from VM '$VMName'..."
Disconnect-VMNetworkAdapter -VMName $VMName

# Give a small delay to ensure disconnection
Start-Sleep -Seconds 2

# Remove and re-add the network adapter (optional but ensures a clean reset)
Write-Host "Removing network adapter..."
Remove-VMNetworkAdapter -VMName $VMName -Confirm:$false

Start-Sleep -Seconds 2  # Wait before re-adding

Write-Host "Re-adding network adapter and connecting to '$VmSwitch'..."
Add-VMNetworkAdapter -VMName $VMName -SwitchName $VmSwitch

# Verify the connection
$adapterAfter = Get-VMNetworkAdapter -VMName $VMName
if ($adapterAfter -and $adapterAfter.SwitchName -eq $VmSwitch) {
    Write-Host "Success: Network adapter is now connected to '$VmSwitch'." -ForegroundColor Green
} else {
    Write-Host "Warning: Failed to attach the network adapter to '$VmSwitch'." -ForegroundColor Yellow
}
