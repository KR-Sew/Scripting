param (
    [Parameter(Mandatory=$true)]
    [string]$VMNameString,  # Name of the VM

    [Parameter(Mandatory=$true)]
    [string]$SnapshotName  # Snapshot name should be a string

)

# Get VM by partial name match
$VM = Get-VM | Where-Object { $_.Name -like "*$VMNameString*" }

# Ensure VM is found before proceeding
if ($VM) {
    Checkpoint-VM -Name $VM.Name -SnapshotName $SnapshotName
    Write-Host "Checkpoint '$SnapshotName' created for VM '$($VM.Name)'" -ForegroundColor Green
} else {
    Write-Host "VM matching '*$VMNameString*' not found." -ForegroundColor Red
}
