param (
    [Parameter(Mandatory = $true)]
    [string]$VMName
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Restart the VM ensuring it stops first
try {
    Stop-VM -Name $VMName -Force -ErrorAction Stop
    while ((Get-VM -Name $VMName).State -ne 'Off') {
        Start-Sleep -Seconds 2
    }
    Start-VM -Name $VMName -ErrorAction Stop
    Write-Host "VM '$VMName' has been reloaded successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to reload VM '$VMName': $_" -ForegroundColor Red
}
