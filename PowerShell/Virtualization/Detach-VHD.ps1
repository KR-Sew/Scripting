param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$ControllerType,

    [Parameter(Mandatory = $true)]
    [int]$ControllerNumber,

    [Parameter(Mandatory = $true)]
    [int]$LUN
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Get the hard drive
$vmHardDrive = Get-VMHardDiskDrive -VMName $VMName |
    Where-Object { $_.ControllerType -eq $ControllerType -and $_.ControllerNumber -eq $ControllerNumber -and $_.ControllerLocation -eq $LUN }

if (-not $vmHardDrive) {
    Write-Host "No VHD found at ControllerType: $ControllerType, ControllerNumber: $ControllerNumber, LUN: $LUN on VM '$VMName'." -ForegroundColor Yellow
    exit 0
}

# Remove the VHD
try {
    Remove-VMHardDiskDrive -VMHardDiskDrive $vmHardDrive -Confirm:$false
    Write-Host "VHD detached from VM '$VMName' at ControllerType: $ControllerType, ControllerNumber: $ControllerNumber, LUN: $LUN." -ForegroundColor Green
} catch {
    Write-Host "Failed to detach VHD: $_" -ForegroundColor Red
}
