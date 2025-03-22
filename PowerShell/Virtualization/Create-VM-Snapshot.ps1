# Define a function to create a Hyper-V VM snapshot

param (
    [Parameter(Mandatory=$true)]
    [string]$VMNameString,                # Name of the VM
    [int]$SnapshotName,             # Memory size in MB
    [int]$MinMemoryMB 
)
$VMName = Get-VM | Where-Object { $_.Name -like "*$VMNameSting*" }
Checkpoint-VM -Name $VMName -SnapshotName $SnapshotName
# (Get-VM | Where-Object { $_.Name -like "*Deb*" }).Name