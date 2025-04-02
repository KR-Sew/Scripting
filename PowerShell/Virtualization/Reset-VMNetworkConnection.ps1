param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,       # Name of the existing VM

    [Parameter(Mandatory = $true)]
    [string]$VmSwitch   # New vlan ID for set up
   
)
# Disconnect the network adapter
Disconnect-VMNetworkAdapter -VMName $VMName -SwitchName $VmSwitch

# Reconnect the network adapter
Connect-VMNetworkAdapter -VMName $VMName -SwitchName $VmSwitch

# Verify the connection
Get-VMNetworkAdapter -VMName $VMName