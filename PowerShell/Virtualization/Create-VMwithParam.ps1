# Define a function to create a Hyper-V VM with configurable parameters

    param (
        [Parameter(Mandatory=$true)]
        [string]$VMName,                # Name of the VM
        [int]$MemorySizeMB,             # Memory size in MB
        [int]$MinMemoryMB ,  # Minimum memory for dynamic allocation
        [int]$MaxMemoryMB ,  # Maximum memory for dynamic allocation
        [int]$VHDSizeGB,                # VHD size in GB
        [int]$CoreCount,                # Number of virtual processors
        [int]$VLANID,
        [Parameter(Mandatory= $true)]
        [ValidateSet("1","2")]                   # VLAN ID for the network
        [int]$Generation,               # VM Generation: 1 or 2
        [bool]$EnableSecureBoot,        # Enable or disable Secure Boot
        [bool]$EnableSRVIO,           # Enable or disable SR-IOV
        [string]$State ,                # Enable or disable system state
        [string]$SecureBootTemplate,     # Point Security boot templates
        [string]$ISOPath,         # Path to the ISO, leave blank to skip
        [bool]$AttachISO          # Set to $true to attach an ISO, $false to skip

        )

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
      $DefSRVIO = "On"
      $DefSecureBoot = "On"              # Secure boot value
      $DefSecureBootTemplate = "MicrosoftUEFICertificateAuthority"  # Default template for Windows VMs
      $DefState = "On"
      $DefISOPath =""
      $DefAttachISO = "On"

# Check value $VMName (Default: $DefaultVMName)
if (-not $VMName) { $VMName = $DefaultVMName }

# Check value $MemoryStartup (Default: $DefaultMemoryStartup) 
if (-not $MemoryStartup) { $MemoryStartup = $DefaultMemoryStartup }

# Check value $MemoryMinimum (Default: $DefaultMemoryMinimum) 
if (-not $MemoryMinimum) { $MemoryMinimum = $DefaultMemoryMinimum }

# Check value $MemoryMaximum (Default: $DefaultMemoryMaximum)
if (-not $MemoryMaximum) { $MemoryMaximum = $DefaultMemoryMaximum }

# Check value $ProcessorCount (Default: $DefaultProcessorCount) 
if (-not $ProcessorCount) { $ProcessorCount = $DefaultProcessorCount }

# Check value $VolumeSizeGB (Default: $DefaultVolumeSizeGB) 
if (-not $VolumeSizeGB) { $VolumeSizeGB = $DefaultVolumeSizeGB }

# Check value $VHDPath (Default: $DefaultVHDPath)
if (-not $VHDPath) { $VHDPath = $DefaultVHDPath }

# Check value $ConfigPath (Default: $DefaultConfigPath) 
if (-not $ConfigPath) { $ConfigPath = $DefaultConfigPath }

# Check value $SwitchName (Default: $DefaultSwitchName) 
if (-not $SwitchName) { $SwitchName = $DefaultSwitchName }

# Check value $VLANID (Default: $DefaultVLANID) 
if (-not $VLANID) { $VLANID = $DefaultVLANID }

if (-not $EnableSRVIO) { $EnableSRVIO = $DefSRVIO }

# Check value $VMSecureBoot (Default: $DefSecureBoot)
if (-not $EnableSecureBoot) { $EnableSecureBoot = $DefSecureBoot }

# Check value $VMSecureBoot (Default: $DefSecureBootTemplate)
if (-not $SecureBootTemplate) { $SecureBootTemplate = $DefSecureBootTemplate }

# Check value $State (Default: $DefState)
if (-not $State) { $State = $DefState }

if (-not $AttachISO) { $AttachISO = $DefAttachISO }

if (-not $ISOPath ) { $ISOPath = $DefISOPath }

# Ensure paths exist
if (-not (Test-Path $VHDPath)) { New-Item -ItemType Directory -Path $VHDPath }
if (-not (Test-Path $ConfigPath)) { New-Item -ItemType Directory -Path $ConfigPath }

# Create the VM
Write-Host "Creating VM $VMName..."
New-VM -Name $VMName `
       -MemoryStartupBytes $MemoryStartup `
       -Generation 2 `
       -Path $ConfigPath\VMs `
       -SwitchName $SwitchName

    # Set processor count
    Set-VMProcessor -VMName $VMName -Count $CoreCount
    
    # Configure memory settings (dynamic memory)
    Write-Host "Configuring Memory Settings..."
    Set-VMMemory -VMName $VMName `
             -StartupBytes $MemoryStartup `
             -DynamicMemoryEnabled $true `
             -MinimumBytes $MemoryMinimum `
             -MaximumBytes $MemoryMaximum 

# Paths for the VHDX files
$VHDFile = Join-Path -Path $VHDPath\VHDs\$VMName -ChildPath "$VMName.vhdx"
      
# Create and attach a new VHDX
Write-Host "Creating VHDX at $VHDFile with size ${VolumeSizeGB}GB..."
New-VHD -Path $VHDFile -Dynamic -SizeBytes ($VolumeSizeGB)
Add-VMHardDiskDrive -VMName $VMName -Path $VHDFile
   
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
    # Configure network adapter VLAN if specified
    if ($VLANID -ne 0) {
        Write-Host "Configuring VLAN ID $VLANID for VM $VMName..."
        Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId $VLANID
    }

    # Configure Secure Boot (only for Generation 2 VMs)
    if ($Generation -eq 2 -and $EnableSecureBoot) {
        
        Set-VMFirmware -VMName $VMName -EnableSecureBoot $VMSecureBoot -SecureBootTemplate $SecureBootTemplate
    } elseif ($Generation -eq 2 -and -not $EnableSecureBoot) {
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
    }

    # Enable or disable SR-IOV
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

# Start the VM (optional)
if ($State) {
    Start-VM -Name $VMName
        Write-Host "VM '$VMName' has been created and started"
    } else {
       Write-Host "VM '$VMName' has been created and not run" 
    }
    
    Write-Host "Virtual Machine '$VMName' created successfully!"
