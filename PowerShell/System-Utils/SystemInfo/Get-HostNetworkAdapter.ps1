<#
.SYNOPSIS
    Backup current NIC/IP configuration before LBFO cleanup or network migration.

.DESCRIPTION
    Collects:
      - Physical adapters
      - Team adapters (LBFO)
      - IP addresses
      - Routes
      - DNS settings
      - Advanced adapter info
      - Cluster networks (if Failover Clustering installed)

    Exports everything to timestamped folder.

.NOTES
    Recommended to run BEFORE:
      - Removing LBFO teams
      - Reconfiguring iSCSI
      - Cluster network changes
#>

[CmdletBinding()]
param(
    [string]$OutputRoot = "C:\NIC-Backup"
)

# ------------------------------------------------------------
# Init
# ------------------------------------------------------------

$Timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$Computer   = $env:COMPUTERNAME
$BackupPath = Join-Path $OutputRoot "$Computer-$Timestamp"

New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

Write-Host ""
Write-Host "[INFO] Backup path:" -ForegroundColor Cyan
Write-Host "       $BackupPath"
Write-Host ""

# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------

function Export-Section {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host "[INFO] Collecting $Name..." -ForegroundColor Yellow

    $TxtFile = Join-Path $BackupPath "$Name.txt"
    $CsvFile = Join-Path $BackupPath "$Name.csv"

    try {
        $Result = & $Command

        $Result | Format-List * | Out-File $TxtFile -Encoding UTF8

        try {
            $Result | Export-Csv $CsvFile -NoTypeInformation -Encoding UTF8
        }
        catch {
            Write-Warning "CSV export failed for $Name"
        }

        Write-Host "[ OK ] $Name exported"
    }
    catch {
        Write-Host "[FAIL] $Name export failed: $_" -ForegroundColor Red
    }

    Write-Host ""
}

# ------------------------------------------------------------
# Basic system info
# ------------------------------------------------------------

systeminfo | Out-File (Join-Path $BackupPath "systeminfo.txt")

# ------------------------------------------------------------
# Adapters
# ------------------------------------------------------------

Export-Section -Name "NetAdapter" -Command {
    Get-NetAdapter | Sort-Object Name
}

Export-Section -Name "NetAdapterAdvancedProperty" -Command {
    Get-NetAdapterAdvancedProperty
}

Export-Section -Name "NetAdapterBinding" -Command {
    Get-NetAdapterBinding
}

Export-Section -Name "NetAdapterHardwareInfo" -Command {
    Get-NetAdapterHardwareInfo
}

# ------------------------------------------------------------
# LBFO Teaming
# ------------------------------------------------------------

if (Get-Command Get-NetLbfoTeam -ErrorAction SilentlyContinue) {

    Export-Section -Name "NetLbfoTeam" -Command {
        Get-NetLbfoTeam
    }

    Export-Section -Name "NetLbfoTeamMember" -Command {
        Get-NetLbfoTeamMember
    }

    Export-Section -Name "NetLbfoTeamNic" -Command {
        Get-NetLbfoTeamNic
    }
}

# ------------------------------------------------------------
# IP Configuration
# ------------------------------------------------------------

Export-Section -Name "NetIPAddress" -Command {
    Get-NetIPAddress | Sort-Object InterfaceAlias
}

Export-Section -Name "NetIPConfiguration" -Command {
    Get-NetIPConfiguration
}

Export-Section -Name "DnsClient" -Command {
    Get-DnsClient
}

Export-Section -Name "DnsClientServerAddress" -Command {
    Get-DnsClientServerAddress
}

Export-Section -Name "NetRoute" -Command {
    Get-NetRoute
}

# ------------------------------------------------------------
# SMB / iSCSI / MPIO
# ------------------------------------------------------------

if (Get-Command Get-IscsiSession -ErrorAction SilentlyContinue) {

    Export-Section -Name "IscsiSession" -Command {
        Get-IscsiSession
    }

    Export-Section -Name "IscsiTargetPortal" -Command {
        Get-IscsiTargetPortal
    }
}

if (Get-Command Get-MSDSMGlobalDefaultLoadBalancePolicy -ErrorAction SilentlyContinue) {

    Export-Section -Name "MPIO" -Command {
        Get-MSDSMGlobalDefaultLoadBalancePolicy
    }
}

# ------------------------------------------------------------
# Cluster
# ------------------------------------------------------------

if (Get-Service ClusSvc -ErrorAction SilentlyContinue) {

    if ((Get-Service ClusSvc).Status -eq 'Running') {

        Export-Section -Name "ClusterNetwork" -Command {
            Get-ClusterNetwork
        }

        Export-Section -Name "ClusterNetworkInterface" -Command {
            Get-ClusterNetworkInterface
        }

        Export-Section -Name "ClusterNode" -Command {
            Get-ClusterNode
        }
    }
}

# ------------------------------------------------------------
# Legacy exports
# ------------------------------------------------------------

ipconfig /all > (Join-Path $BackupPath "ipconfig-all.txt")
route print > (Join-Path $BackupPath "route-print.txt")

# ------------------------------------------------------------
# Driver info
# ------------------------------------------------------------

driverquery /v > (Join-Path $BackupPath "driverquery.txt")

# ------------------------------------------------------------
# Final
# ------------------------------------------------------------

Write-Host ""
Write-Host "[INFO] NIC configuration backup completed." -ForegroundColor Green
Write-Host "[INFO] Files saved to:" -ForegroundColor Cyan
Write-Host "       $BackupPath"
Write-Host ""