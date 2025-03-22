param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$ISOPath
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Check if the ISO file exists
if (-not (Test-Path $ISOPath)) {
    Write-Host "ISO file '$ISOPath' not found." -ForegroundColor Red
    exit 1
}

# Add the ISO to the VM's DVD drive
try {
    $dvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue
    if ($dvdDrive) {
        Set-VMDvdDrive -VMName $VMName -Path $ISOPath
    } else {
        Add-VMDvdDrive -VMName $VMName -Path $ISOPath
    }
    Write-Host "ISO '$ISOPath' added to VM '$VMName' and set to load at startup." -ForegroundColor Green
} catch {
    Write-Host "Failed to add ISO: $_" -ForegroundColor Red
}
