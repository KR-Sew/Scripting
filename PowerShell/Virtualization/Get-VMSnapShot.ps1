param (
    [string]$VMName
)

# Check if the VMName parameter is provided
if (-not $VMName) {
    Write-Host "Usage: .\Get-VMSnapshots.ps1 -VMName <VMName>"
    exit
}

# Get the VM
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue

# Check if the VM exists
if (-not $VM) {
    Write-Host "Error: Virtual machine '$VMName' not found."
    exit
}

# Get snapshots (checkpoints) of the VM
$Snapshots = Get-VMSnapshot -VMName $VMName -ErrorAction SilentlyContinue

# Check if there are any snapshots
if (-not $Snapshots) {
    Write-Host "No snapshots found for VM '$VMName'."
    exit
}

# Display snapshot details
Write-Host "Snapshots for VM '$VMName':`n"
$Snapshots | Format-Table Name, CreationTime, SnapshotType -AutoSize
