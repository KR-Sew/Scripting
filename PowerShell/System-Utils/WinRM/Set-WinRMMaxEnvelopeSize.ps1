#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Increases the WinRM maximum SOAP envelope size.

.DESCRIPTION
    Resolves "The estimated response packet size exceeded the maximum allowed
    envelope size" by changing MaxEnvelopeSizekb, restarting WinRM, and
    confirming the applied value.

.EXAMPLE
    .\Set-WinRMMaxEnvelopeSize.ps1

.EXAMPLE
    .\Set-WinRMMaxEnvelopeSize.ps1 -MaxEnvelopeSizeKB 16384
#>

[CmdletBinding()]
param (
    [Parameter()]
    [ValidateRange(512, 1048576)]
    [int]$MaxEnvelopeSizeKB = 8192
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -----------------------------------------------------------------------------
# Display helpers
# -----------------------------------------------------------------------------
function Write-Section {
    param ([Parameter(Mandatory)][string]$Title)

    Write-Host ''
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ('=' * 79) -ForegroundColor DarkGray
}

function Write-Info {
    param ([Parameter(Mandatory)][string]$Message)

    Write-Host '[INFO] ' -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Ok {
    param ([Parameter(Mandatory)][string]$Message)

    Write-Host '[ OK ] ' -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Fail {
    param ([Parameter(Mandatory)][string]$Message)

    Write-Host '[FAIL] ' -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Format-Size {
    param ([Parameter(Mandatory)][long]$SizeKB)

    $sizeMB = $SizeKB / 1024
    return ('{0:N0} KB ({1:N2} MB / {2:N0} bytes)' -f $SizeKB, $sizeMB, ($SizeKB * 1KB))
}

# -----------------------------------------------------------------------------
# WinRM configuration helpers
# -----------------------------------------------------------------------------
function Get-MaxEnvelopeSize {
    $item = Get-Item -Path 'WSMan:\localhost\MaxEnvelopeSizekb'
    return [int]$item.Value
}

function Set-MaxEnvelopeSize {
    param ([Parameter(Mandatory)][int]$SizeKB)

    Set-Item -Path 'WSMan:\localhost\MaxEnvelopeSizekb' -Value $SizeKB -Force
}

function Restart-WinRMService {
    Write-Info 'Restarting the Windows Remote Management service...'
    Restart-Service -Name 'WinRM' -Force

    $service = Get-Service -Name 'WinRM'
    $service.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,
        [TimeSpan]::FromSeconds(30))

    if ($service.Status -ne 'Running') {
        throw "The WinRM service did not return to the Running state."
    }
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
try {
    Write-Section 'WinRM maximum envelope size configuration'

    $service = Get-Service -Name 'WinRM' -ErrorAction Stop
    Write-Ok "WinRM service found. Current status: $($service.Status)."

    $currentSizeKB = Get-MaxEnvelopeSize
    Write-Info "Current size : $(Format-Size -SizeKB $currentSizeKB)"
    Write-Info "Requested size: $(Format-Size -SizeKB $MaxEnvelopeSizeKB)"

    if ($currentSizeKB -eq $MaxEnvelopeSizeKB) {
        Write-Ok 'The requested value is already configured; no change is required.'

        if ($service.Status -ne 'Running') {
            Write-Info 'WinRM is not running. Starting the service...'
            Start-Service -Name 'WinRM'
        }
    }
    else {
        Write-Info 'Applying the new MaxEnvelopeSizekb value...'
        Set-MaxEnvelopeSize -SizeKB $MaxEnvelopeSizeKB
        Write-Ok 'The WinRM configuration has been updated.'

        Restart-WinRMService
        Write-Ok 'The WinRM service restarted successfully.'
    }

    $appliedSizeKB = Get-MaxEnvelopeSize

    Write-Section 'Verification'
    Write-Ok "Applied size: $(Format-Size -SizeKB $appliedSizeKB)"
    Write-Ok "WinRM status: $((Get-Service -Name 'WinRM').Status)"

    if ($appliedSizeKB -ne $MaxEnvelopeSizeKB) {
        throw "Verification failed. Requested $MaxEnvelopeSizeKB KB, but WinRM reports $appliedSizeKB KB."
    }

    Write-Host ''
    Write-Host 'Configuration completed successfully.' -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ''
    Write-Fail $_.Exception.Message
    Write-Host 'Run this script from an elevated Windows PowerShell console.' -ForegroundColor Yellow
    exit 1
}
