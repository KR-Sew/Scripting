param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,       # Name of the existing VM

    [Parameter(Mandatory = $true)]
    [string]$VmSwitch      # New virtual switch name to connect to
)

# Check if VM exists
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

# Save current VLAN ID
$vlanInfo = Get-VMNetworkAdapterVlan -VMName $VMName -ErrorAction SilentlyContinue
$originalVlanID = if ($vlanInfo -and $vlanInfo.AccessVlanId) { $vlanInfo.AccessVlanId } else { $null }

Write-Host "Current VLAN ID: $originalVlanID"

# Disconnect and remove network adapter
Write-Host "Disconnecting and removing network adapter from VM '$VMName'..."
Disconnect-VMNetworkAdapter -VMName $VMName
Start-Sleep -Seconds 2

Remove-VMNetworkAdapter -VMName $VMName -Confirm:$false
Start-Sleep -Seconds 2  # Wait before re-adding

# Re-add network adapter and connect to the new switch
Write-Host "Re-adding network adapter and connecting to '$VmSwitch'..."
Add-VMNetworkAdapter -VMName $VMName -SwitchName $VmSwitch

# Restore VLAN ID if it was set before
if ($originalVlanID) {
    Write-Host "Restoring VLAN ID: $originalVlanID..."
    Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId $originalVlanID
}

# Verify the connection
$adapterAfter = Get-VMNetworkAdapter -VMName $VMName
if ($adapterAfter -and $adapterAfter.SwitchName -eq $VmSwitch) {
    Write-Host "✅ Success: Network adapter is now connected to '$VmSwitch' with VLAN ID: $originalVlanID." -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: Failed to attach the network adapter to '$VmSwitch'." -ForegroundColor Yellow
}
