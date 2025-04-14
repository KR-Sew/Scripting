# Set default parameters (modify as needed)
$DefaultVMName = "NewVM"
$DefaultMemoryStartup = 2048MB    # Startup Memory
$DefaultMemoryMinimum = 2048MB   # Minimum Memory
$DefaultMemoryMaximum = 8192MB   # Maximum Memory
$DefaultProcessorCount = 2       # Number of Processor Cores
$DefaultVHDPath = (Get-VMHost).VirtualHardDiskPath
$DefaultConfigPath = (Get-VMHost).VirtualMachinePath
$DefaultVolumeSizeGB = 50GB        # Size of the VHD (in GB)
$DefaultVLANID = 0               # Default VLAN ID
$DefaultSwitchName = "ExternalSwitch01"  # Replace with a valid switch name
$DefSecureBoot = "On"              # Secure boot value
$DefISOPath =""
$DefAttachISO = "On"
# Prompt for VM details or use default values
$VMName = Read-Host "Enter VM Name (Default: $DefaultVMName)" 
if (-not $VMName) { $VMName = $DefaultVMName }

$MemoryStartup = Read-Host "Enter Startup Memory in MB (Default: $DefaultMemoryStartup)"
if (-not $MemoryStartup) { $MemoryStartup = $DefaultMemoryStartup }

$MemoryMinimum = Read-Host "Enter Minimum Memory in MB (Default: $DefaultMemoryMinimum)"
if (-not $MemoryMinimum) { $MemoryMinimum = $DefaultMemoryMinimum }

$MemoryMaximum = Read-Host "Enter Maximum Memory in MB (Default: $DefaultMemoryMaximum)" 
if (-not $MemoryMaximum) { $MemoryMaximum = $DefaultMemoryMaximum }

$ProcessorCount = Read-Host "Enter Number of Processors (Default: $DefaultProcessorCount)" 
if (-not $ProcessorCount) { $ProcessorCount = $DefaultProcessorCount }

$VolumeSizeGB = Read-Host "Enter Volume Size in GB (Default: $DefaultVolumeSizeGB)" 
if (-not $VolumeSizeGB) { $VolumeSizeGB = $DefaultVolumeSizeGB }

$VHDPath = Read-Host "Enter VHD Path (Default: $DefaultVHDPath)" 
if (-not $VHDPath) { $VHDPath = $DefaultVHDPath }

$ConfigPath = Read-Host "Enter Config Path (Default: $DefaultConfigPath)" 
if (-not $ConfigPath) { $ConfigPath = $DefaultConfigPath }

$SwitchName = Read-Host "Enter Virtual Switch Name (Default: $DefaultSwitchName)" 
if (-not $SwitchName) { $SwitchName = $DefaultSwitchName }

$VLANID = Read-Host "Enter VLAN ID (Default: $DefaultVLANID)" 
if (-not $VLANID) { $VLANID = $DefaultVLANID }

$VMSecureBoot = Read-Host "Enter Secure boot flag (Default: $DefSecureBoot)"
if (-not $VMSecureBoot) { $VMSecureBoot = $DefSecureBoot }

# Ensure paths exist
if (-not (Test-Path $VHDPath)) { New-Item -ItemType Directory -Path $VHDPath }
if (-not (Test-Path $ConfigPath)) { New-Item -ItemType Directory -Path $ConfigPath }

$AttachISO = Read-Host "Enter attaching ISO (Default: $DefAttachISO)"
if (-not $AttachISO) { $AttachISO = $DefAttachISO }

$ISOPath = Read-Host "Enter ISO path (Default: $DefISOPath)"
if (-not $ISOPath ) { $ISOPath = $DefISOPath }

# Paths for the VHDX files
$VHDFile = Join-Path -Path $VHDPath\VHDs\$VMName -ChildPath "$VMName.vhdx"


# Create the VM
Write-Host "Creating VM $VMName..."
New-VM -Name $VMName `
       -MemoryStartupBytes  ($MemoryStartup / 1) `
       -Generation 2 `
       -Path $ConfigPath\VMs `
       -SwitchName $SwitchName

    # Configure the processor count
    Set-VMProcessor -VMName $VMName -Count $ProcessorCount

    # Configure memory settings (dynamic memory)
    Write-Host "Configuring Memory Settings..."
    Set-VMMemory -VMName $VMName `
             -StartupBytes ($MemoryStartup / 1) `
             -DynamicMemoryEnabled $true `
             -MinimumBytes ($MemoryMinimum / 1)`
             -MaximumBytes ($MemoryMaximum / 1) 
             
# Attach ISO if $AttachISO is true
if ($AttachISO -and $ISOPath) {
    # Validate that the ISO file exists
    if (-not (Test-Path -Path $ISOPath)) {
        Write-Host "Error: The ISO file '$ISOPath' does not exist." -ForegroundColor Red
        return
    }

    # Attach the ISO to the virtual DVD drive
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath
    Write-Host "ISO '$ISOPath' attached to VM '$VMName'."
    # Configure the VM to boot from the ISO
    Set-VMFirmware -VMName $VMName -FirstBootDevice $(Get-VMDvdDrive -VMName $VMName)

} else {
    Write-Host "No ISO will be attached to VM '$VMName'." -ForegroundColor Yellow
}
# Create and attach a new VHDX
Write-Host "Creating VHDX at $VHDFile with size ${VolumeSizeGB}GB..."
New-VHD -Path $VHDFile -Dynamic -SizeBytes ($VolumeSizeGB)
Add-VMHardDiskDrive -VMName $VMName -Path $VHDFile

# Configure network adapter VLAN if specified
if ($VLANID -ne 0) {
    Write-Host "Configuring VLAN ID $VLANID for VM $VMName..."
    Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId $VLANID
}

# Enable Windows Server secure boot type
Write-Host "Enabling Server secure boot type..."
Set-VMFirmware -VMName $VMName -EnableSecureBoot $VMSecureBoot `
               -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# Enable SR-IOV if requested
if ($EnableSRVIO) {
    # Verify that the virtual switch is SR-IOV capable
    $Switch = Get-VMSwitch -Name $SwitchName
    if (-not $Switch.IovEnabled) {
        Write-Error "The virtual switch '$SwitchName' does not support SR-IOV."
    } else {
        # Set SR-IOV weight for the VM's network adapter
        Set-VMNetworkAdapter -VMName $VMName -IovWeight 100
        Write-Host "SR-IOV enabled for VM '$VMName' with IovWeight 100."
    }
}




# Start the VM

if ($On) {
    Start-VM -Name $VMName
        Write-Host "VM '$VMName' has been created and started"
    } else {
       Write-Host "VM '$VMName' has been created and not run" 
    }
    
Write-Host "Starting VM $VMName..."
Start-VM -Name $VMName

Write-Host "VM $VMName created, configured, and started successfully!"
