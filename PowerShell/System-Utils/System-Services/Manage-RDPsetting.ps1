<#
.SYNOPSIS
    Enable or disable Remote Desktop (RDP) on Windows Server 2025.

.DESCRIPTION
    This script configures the registry, firewall, and RDP service
    to either enable or disable Remote Desktop based on user choice.

.PARAMETER Enable
    Enables Remote Desktop.

.PARAMETER Disable
    Disables Remote Desktop.

.EXAMPLE
    .\Manage-RDP.ps1 -Enable

.EXAMPLE
    .\Manage-RDP.ps1 -Disable
#>

param(
    [Parameter(Mandatory=$true, ParameterSetName="Enable")]
    [switch]$Enable,

    [Parameter(Mandatory=$true, ParameterSetName="Disable")]
    [switch]$Disable
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

if ($Enable) {
    Enable-RDP
} elseif ($Disable) {
    Disable-RDP
}
