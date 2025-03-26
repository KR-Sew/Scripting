param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Get the DVD drive
$dvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
if (-not $dvdDrive) {
    Write-Host "No DVD drive found on VM '$VMName'." -ForegroundColor Yellow
    exit 0
}

# Remove the ISO
try {
    Set-VMDvdDrive -VMName $VMName -Path $null
    Write-Host "ISO detached from VM '$VMName'." -ForegroundColor Green
} catch {
    Write-Host "Failed to detach ISO: $_" -ForegroundColor Red
}
