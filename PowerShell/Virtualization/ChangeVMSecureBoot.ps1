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
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Get the current firmware settings
$vmFirmware = Get-VMFirmware -VMName $VMName | Select-Object -ExpandProperty SecureBootTemplate

# Update Secure Boot settings
try {
    if ($EnableSecureBoot) {
        if ($SecureBootTemplate) {
            Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate $SecureBootTemplate
            Write-Host "Secure Boot enabled with template '$SecureBootTemplate' for VM '$VMName'." -ForegroundColor Green
        } else {
            Set-VMFirmware -VMName $VMName -EnableSecureBoot On
            Write-Host "Secure Boot enabled for VM '$VMName'." -ForegroundColor Green
            Write-Host "Secure boot template $vmFirmware has been changed successfully"
        }
    } else {
        Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
        Write-Host "Secure Boot disabled for VM '$VMName'." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Failed to update Secure Boot settings: $_" -ForegroundColor Red
}
