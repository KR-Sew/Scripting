param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Get all snapshots for the VM
$snapshots = Get-VMSnapshot -VMName $VMName

# Check if snapshots exist
if ($snapshots.Count -eq 0) {
    Write-Host "No snapshots found for VM '$VMName'." -ForegroundColor Yellow
    exit 0
}

# Display snapshots with index numbers
Write-Host "`nAvailable Snapshots for VM '$VMName':" -ForegroundColor Cyan
for ($i = 0; $i -lt $snapshots.Count; $i++) {
    Write-Host "$i. $($snapshots[$i].Name) - Created: $($snapshots[$i].CreationTime)"
}

# Ask the user to select a snapshot
$selection = Read-Host "`nEnter the number of the snapshot to delete"

# Validate input
if ($selection -match '^\d+$' -and [int]$selection -ge 0 -and [int]$selection -lt $snapshots.Count) {
    $selectedSnapshot = $snapshots[$selection].Name
    Remove-VMSnapshot -VMName $VMName -Name $selectedSnapshot -Confirm:$false
    Write-Host "`nSnapshot '$selectedSnapshot' deleted successfully." -ForegroundColor Green
} else {
    Write-Host "`nInvalid selection. No snapshots were deleted." -ForegroundColor Red
}
