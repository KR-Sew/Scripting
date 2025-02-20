# Variables
$VMName = "MyNewVM"                # Name of the VM
$VMPath = "C:\Hyper-V\VMs\$VMName" # Path where the VM files will be stored
$VHDPath = "$VMPath\$VMName.vhdx"  # Path for the virtual hard disk
$SwitchName = "Virtual Switch"      # Name of the virtual switch
$MemoryStartupBytes = 2GB           # Startup memory for the VM
$ProcessorCount = 2                 # Number of virtual processors
$DiskSizeBytes = 20GB               # Size of the virtual hard disk
$VlanId = 100                       # VLAN ID to assign to the network adapter

# Create the VM directory
New-Item -ItemType Directory -Path $VMPath -Force

# Create the virtual hard disk
New-VHD -Path $VHDPath -SizeBytes $DiskSizeBytes -Dynamic

# Create the VM
New-VM -Name $VMName -MemoryStartupBytes $MemoryStartupBytes -BootDevice VHD -SwitchName $SwitchName -Path $VMPath

# Add the virtual hard disk to the VM
Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath

# Set the number of processors
Set-VMProcessor -VMName $VMName -Count $ProcessorCount

# Set the VLAN ID for the network adapter
$NetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
Set-VMNetworkAdapter -NetworkAdapter $NetworkAdapter -AccessMode Access -VlanId $VlanId

# Start the VM
Start-VM -VMName $VMName

# Output the VM details
Get-VM -Name $VMName
