param (
    [string]$VMName,
    [string]$DiskType,       # "VHD" or "DVD"
    [string]$VHDPath,        # Path for VHD (if VHD is selected)
    [int]$VHDDiskSize = 20,  # Default VHD size in GB
    [string]$VHDType = "Dynamic", # "Dynamic" or "Fixed"
    [int]$SCSIController = 0, # Default SCSI Controller Index
    [int]$SCSIPlacement = 0   # Default SCSI Location
)

# Validate input
if (-not $VMName) {
    Write-Host "Error: Please specify a VM name using -VMName parameter."
    exit
}

# Check if VM exists
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Host "Error: VM '$VMName' not found."
    exit
}

# Validate DiskType
if ($DiskType -notin @("VHD", "DVD")) {
    Write-Host "Error: Invalid DiskType. Use 'VHD' or 'DVD'."
    exit
}

if ($DiskType -eq "VHD") {
    # Ensure VHDPath is provided
    if (-not $VHDPath) {
        $VHDPath = "C:\Hyper-V\$VMName-Disk.vhdx"
    }

    # Create a new VHD if it does not exist
    if (-not (Test-Path $VHDPath)) {
        Write-Host "Creating VHD at: $VHDPath"
        New-VHD -Path $VHDPath -SizeBytes ($VHDDiskSize * 1GB) -Dynamic:($VHDType -eq "Dynamic")
    }

    # Attach VHD to VM using the specified SCSI Controller and Location
    Write-Host "Attaching VHD to VM '$VMName' on SCSI Controller $SCSIController, Location $SCSIPlacement..."
    Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath -ControllerType SCSI -ControllerNumber $SCSIController -ControllerLocation $SCSIPlacement
}

if ($DiskType -eq "DVD") {
    # Find an available IDE Controller
    # $IDEController = 1  # IDE 1 is often used for CD/DVD
    Write-Host "Attaching DVD drive to VM '$VMName' on IDE Controller $IDEController..."
    Add-VMDvdDrive -VMName $VMName -ControllerNumber $SCSIController -ControllerLocation $SCSIPlacement
}

Write-Host "Operation completed successfully."
