param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$BaseCheckpointPath
)

# Validate VM
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Error "VM '$VMName' not found."
    exit 1
}

# Construct full path: BasePath\VMName
$CheckpointPath = Join-Path -Path $BaseCheckpointPath -ChildPath $VMName

# Create folder if it doesn't exist
if (-not (Test-Path $CheckpointPath)) {
    try {
        New-Item -Path $CheckpointPath -ItemType Directory -Force | Out-Null
        Write-Host "Created checkpoint folder: $CheckpointPath"
    } catch {
        Write-Error "Failed to create folder: $_"
        exit 1
    }
}

# Set checkpoint file location
try {
    Set-VM -Name $VMName -CheckpointFileLocation $CheckpointPath
    Write-Host "Checkpoint file location set to: $CheckpointPath"
} catch {
    Write-Error "Failed to set checkpoint location: $_"
}
