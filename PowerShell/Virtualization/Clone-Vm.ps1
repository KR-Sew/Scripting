param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,       # Name of the existing VM

    [Parameter(Mandatory = $true)]
    [string]$NewVMName,    # Name for the cloned VM

    [Parameter(Mandatory = $true)]
    [string]$SwitchName    # Virtual switch to use for networking
)

# Check if the original VM exists
$OriginalVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $OriginalVM) {
    Write-Host "❌ Error: The VM '$VMName' does not exist." -ForegroundColor Red
    exit 1
}

# Get the VM's disk path (AVHDX or VHDX)
$DiskPath = (Get-VMHardDiskDrive -VMName $VMName).Path
if (-not (Test-Path $DiskPath)) {
    Write-Host "❌ Error: Cannot find the disk file at $DiskPath" -ForegroundColor Red
    exit 1
}

Write-Host "🖥️ Disk found: $DiskPath"

# If the disk is an AVHDX (checkpoint), find the base VHDX
if ($DiskPath -match "\.avhdx$") {
    Write-Host "⚠️ AVHDX detected! Finding base VHDX..."
    
    # Get the parent VHDX
    $ParentVHDX = Get-VHD -Path $DiskPath | Select-Object -ExpandProperty ParentPath
    if (-not $ParentVHDX -or -not (Test-Path $ParentVHDX)) {
        Write-Host "❌ Error: Could not locate the base VHDX. Try merging snapshots first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Base VHDX found: $ParentVHDX"
    $DiskPath = $ParentVHDX
}

# Define new VHD path
$VHDDirectory = Split-Path -Path $DiskPath -Parent
$NewVHDPath = "$VHDDirectory\$NewVMName.vhdx"

# Copy the base VHDX
Write-Host "📁 Copying VHD to $NewVHDPath..."
Copy-Item -Path $DiskPath -Destination $NewVHDPath -Force -ErrorAction Stop

# Create a new VM using the copied VHD
Write-Host "🖥️ Creating new VM: $NewVMName..."
New-VM -Name $NewVMName -MemoryStartupBytes 2GB -Generation 2 -VHDPath $NewVHDPath -SwitchName $SwitchName

# Assign the new MAC address
Set-VMNetworkAdapter -VMName $NewVMName -DynamicMacAddress -MacAddress On

# Start the new VM
Write-Host "🚀 Starting cloned VM..."
Start-VM -Name $NewVMName

Write-Host "✅ Cloning complete! The VM '$NewVMName' is now running with a unique MAC address." -ForegroundColor Green
