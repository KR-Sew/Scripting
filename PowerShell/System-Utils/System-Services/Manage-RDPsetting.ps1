<#
.SYNOPSIS
    Enable, disable, or check the status of Remote Desktop (RDP) on Windows Server 2025.

.DESCRIPTION
    This script configures the registry, firewall, and RDP service
    to either enable, disable, or check the status of Remote Desktop.

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
#>

param(
    [Parameter(Mandatory=$true, ParameterSetName="Enable")]
    [switch]$Enable,

    [Parameter(Mandatory=$true, ParameterSetName="Disable")]
    [switch]$Disable,

    [Parameter(Mandatory=$true, ParameterSetName="Status")]
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

if ($Enable) {
    Enable-RDP
} elseif ($Disable) {
    Disable-RDP
} elseif ($Status) {
    Get-RDPStatus
}
