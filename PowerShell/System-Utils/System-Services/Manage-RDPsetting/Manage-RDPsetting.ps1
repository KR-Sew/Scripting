<#
.SYNOPSIS
    Enable, disable, or check the status of Remote Desktop (RDP) on Windows Server 2025.

.DESCRIPTION
    This script configures the registry, firewall, and RDP service
    to enable, disable, or show the status of Remote Desktop.
    You can combine switches (e.g. -Enable -Status).

.PARAMETER Enable
    Enables Remote Desktop.

.PARAMETER Disable
    Disables Remote Desktop.

.PARAMETER Status
    Shows the current Remote Desktop status.

.EXAMPLE
    .\Manage-RDP.ps1 -Enable

.EXAMPLE
    .\Manage-RDP.ps1 -Disable

.EXAMPLE
    .\Manage-RDP.ps1 -Status

.EXAMPLE
    .\Manage-RDP.ps1 -Enable -Status
#>

param(
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Status
)

function Enable-RDP {
    Write-Host "Enabling Remote Desktop..." -ForegroundColor Green

    # Enable RDP in registry
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

    # Enforce Network Level Authentication (NLA)
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

    # Enable and start RDP service
    Set-Service -Name TermService -StartupType Automatic
    Start-Service -Name TermService

    # Allow firewall rules
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    Write-Host "✅ Remote Desktop has been ENABLED."
}

function Disable-RDP {
    Write-Host "Disabling Remote Desktop..." -ForegroundColor Yellow

    # Disable RDP in registry
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

    # Stop RDP service
    Stop-Service -Name TermService -Force
    Set-Service -Name TermService -StartupType Disabled

    # Block firewall rules
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop"

    Write-Host "❌ Remote Desktop has been DISABLED."
}

function Get-RDPStatus {
    $rdpEnabled = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections -eq 0
    $service = Get-Service -Name TermService
    $firewall = (Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Where-Object { $_.Enabled -eq 'True' })

    if ($rdpEnabled -and $service.Status -eq "Running" -and $firewall) {
        Write-Host "✅ Remote Desktop is ENABLED and ready for connections." -ForegroundColor Green
    } else {
        Write-Host "❌ Remote Desktop is DISABLED or partially misconfigured." -ForegroundColor Red
        Write-Host "   - Registry Enabled: $rdpEnabled"
        Write-Host "   - Service Status  : $($service.Status)"
        Write-Host "   - Firewall Open   : $([bool]$firewall)"
    }
}

# Execute based on switches (can combine)
if ($Enable) { Enable-RDP }
if ($Disable) { Disable-RDP }
if ($Status) { Get-RDPStatus }
