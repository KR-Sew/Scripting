param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [bool]$EnableSecureBoot,

    [Parameter(Mandatory = $false)]
    [ValidateSet("MicrosoftUEFICertificateAuthority", "MicrosoftWindows", "OpenSourceShieldedVM")]
    [string]$SecureBootTemplate
)

# Check if the VM exists
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Check VM state
$wasRunning = $false
if ($vm.State -eq 'Running') {
    Write-Host "VM '$VMName' is running. Stopping VM..." -ForegroundColor Yellow
    try {
        Stop-VM -Name $VMName -Force -ErrorAction Stop
        Write-Host "VM '$VMName' stopped successfully." -ForegroundColor Green
        $wasRunning = $true
    } catch {
        Write-Host "Failed to stop VM '$VMName': $_" -ForegroundColor Red
        exit 1
    }
}

# Get current firmware settings
$vmFirmware = Get-VMFirmware -VMName $VMName | Select-Object -ExpandProperty SecureBootTemplate

# Update Secure Boot settings
try {
    if ($EnableSecureBoot) {
        if ($SecureBootTemplate) {
            Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate $SecureBootTemplate
            Write-Host "Secure Boot enabled with template '$SecureBootTemplate' for VM '$VMName'." -ForegroundColor Green
        } else {
            Set-VMFirmware -VMName $VMName -EnableSecureBoot On
            Write-Host "Secure Boot enabled for VM '$VMName' with existing template '$vmFirmware'." -ForegroundColor Green
        }
    } else {
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
        Write-Host "Secure Boot disabled for VM '$VMName'." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Failed to update Secure Boot settings: $_" -ForegroundColor Red
    exit 1
}

# Optionally restart VM if it was running before
if ($wasRunning) {
    try {
        Start-VM -Name $VMName -ErrorAction Stop
        Write-Host "VM '$VMName' started successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to start VM '$VMName' after firmware update: $_" -ForegroundColor Red
    }
}
