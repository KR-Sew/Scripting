param (
    [string]$VMName,
    
    [Parameter(Mandatory =$true)]
    [ValidateSet("DVD","VHD")]
    [string]$DiskType,       # "VHD" or "DVD"
    
    [string]$VHDPath,        # Path for VHD (if VHD is selected)
    [Int64]$VHDDiskSize = 20,  # Default VHD size in GB
    [Parameter(Mandatory=$true)]
    [ValidateSet("Dynamic","Fixed")]
    [string]$VHDType = "Dynamic", # "Dynamic" or "Fixed"
    [int]$SCSIController = 0, # Default SCSI Controller Index
    [int]$SCSIPlacement = 0   # Default SCSI Location
)

# Validate input
if (-not $VMName) {
    Write-Host "Error: Please specify a VM name using -VMName parameter." -ForegroundColor Red
    exit 1
}

# Check if VM exists
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Host "Error: VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Validate DiskType
if ($DiskType -notin @("VHD", "DVD")) {
    Write-Host "Error: Invalid DiskType. Use 'VHD' or 'DVD'." -ForegroundColor Red
    exit 1
}

# Get default path to VHD folder
$vmHost = Get-VMHost
$basePath = $vmHost.VirtualHardDiskPath
$vmFolderPath = Join-Path $basePath $VMName

# Create VM folder if it doesn't exist
if (-not (Test-Path $vmFolderPath)) {
    New-Item -ItemType Directory -Path $vmFolderPath -ErrorAction Stop | Out-Null
    Write-Host "Created folder: $vmFolderPath" -ForegroundColor DarkCyan
} else {
    Write-Host "Folder already exists: $vmFolderPath" -ForegroundColor DarkYellow
}

if ($DiskType -eq "VHD") {
    # Determine VHD file path
    if (-not $VHDPath) {
        $VHDFilePath = Join-Path $vmFolderPath "$VMName-Disk.vhdx"
    } else {
        # Use provided VHDPath and create subfolder
        $subfolderPath = Join-Path $VHDPath $VMName
        if (-not (Test-Path $subfolderPath)) {
            New-Item -Path $subfolderPath -ItemType Directory -ErrorAction Stop | Out-Null
            Write-Host "Created subfolder: $subfolderPath" -ForegroundColor DarkCyan
        } else {
            Write-Host "Subfolder already exists: $subfolderPath" -ForegroundColor DarkYellow
        }
        $VHDFilePath = Join-Path $subfolderPath "$VMName-Disk.vhdx"
    }

    # Create a new VHD if it does not exist
    if (-not (Test-Path $VHDFilePath)) {
        Write-Host "Creating VHD at: $VHDFilePath" -ForegroundColor Cyan
        try {
            New-VHD -Path $VHDFilePath -SizeBytes ($VHDDiskSize * 1GB) -Dynamic:($VHDType -eq "Dynamic") -ErrorAction Stop
        } catch {
            Write-Host "Error creating VHD: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "VHD already exists: $VHDFilePath" -ForegroundColor DarkYellow
    }

    # Attach VHD to VM
    Write-Host "Attaching VHD to VM '$VMName' on SCSI Controller $SCSIController, Location $SCSIPlacement..." -ForegroundColor Cyan
    try {
        Add-VMHardDiskDrive -VMName $VMName -Path $VHDFilePath -ControllerType SCSI -ControllerNumber $SCSIController -ControllerLocation $SCSIPlacement -ErrorAction Stop
    } catch {
        Write-Host "Error attaching VHD: $_" -ForegroundColor Red
        exit 1
    }
}

if ($DiskType -eq "DVD") {
    Write-Host "Attaching DVD drive to VM '$VMName' on SCSI Controller $SCSIController..." -ForegroundColor Cyan
    try {
        Add-VMDvdDrive -VMName $VMName -ControllerNumber $SCSIController -ErrorAction Stop
    } catch {
        Write-Host "Error attaching DVD drive: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Operation completed successfully." -ForegroundColor Green