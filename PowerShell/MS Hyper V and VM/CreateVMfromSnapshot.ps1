param (
    [string]$VMName,       # Name of the existing VM
    [string]$NewVMName,    # Name for the cloned VM
    [string]$SwitchName    # Virtual switch to use for networking
)

# Check if VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "Error: The VM '$VMName' does not exist." -ForegroundColor Red
    exit
}

# Create a checkpoint (snapshot)
$CheckpointName = "$VMName-Snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host "Creating snapshot: $CheckpointName..."
Checkpoint-VM -Name $VMName -SnapshotName $CheckpointName

# Get the latest checkpoint
$Checkpoint = Get-VMSnapshot -VMName $VMName | Sort-Object CreationTime -Descending | Select-Object -First 1
if (-not $Checkpoint) {
    Write-Host "Error: Snapshot creation failed." -ForegroundColor Red
    exit
}

Write-Host "Snapshot created successfully: $Checkpoint.Name"

# Get the original VM's VHD path
$VHDPath = (Get-VMHardDiskDrive -VMName $VMName).Path
if (-not (Test-Path $VHDPath)) {
    Write-Host "Error: Cannot find the VHD file at $VHDPath" -ForegroundColor Red
    exit
}

Write-Host "VHD found: $VHDPath"

# Create the new VM
Write-Host "Creating new VM: $NewVMName..."
New-VM -Name $NewVMName -MemoryStartupBytes 2GB -Generation 2 -VHDPath $VHDPath -SwitchName $SwitchName

# Apply the snapshot to the new VM
Write-Host "Applying snapshot to new VM..."
Restore-VMSnapshot -VMName $NewVMName -Name $Checkpoint.Name -Confirm:$false

# Start the new VM
Write-Host "Starting cloned VM..."
Start-VM -Name $NewVMName

Write-Host "✅ Cloning complete! The VM '$NewVMName' is now running." -ForegroundColor Green
