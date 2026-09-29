#requires -Version 5.1

<#
.SYNOPSIS
    Enables, disables, or reports the IPv6 checkbox on Windows network adapters.

.DESCRIPTION
    Changes the Microsoft TCP/IP version 6 adapter binding (Component ID
    ms_tcpip6). This is the same binding represented by the "Internet Protocol
    Version 6 (TCP/IPv6)" checkbox in the adapter Properties window.

.EXAMPLE
    .\Manage-IPv6Binding.ps1 -Action Status

.EXAMPLE
    .\Manage-IPv6Binding.ps1 -Action Disable -AdapterName 'Ethernet'

.EXAMPLE
    .\Manage-IPv6Binding.ps1 -Action Enable -AdapterName 'Ethernet','Wi-Fi'

.EXAMPLE
    .\Manage-IPv6Binding.ps1 -Action Disable -AdapterName '*' -IncludeVirtual -WhatIf
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Enable', 'Disable', 'Status')]
    [string]$Action,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string[]]$AdapterName = @('*'),

    [Parameter()]
    [switch]$IncludeVirtual
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-ColorMessage {
    param(
        [Parameter(Mandatory)][ValidateSet('INFO', 'OK', 'WARN', 'FAIL')]
        [string]$Type,
        [Parameter(Mandatory)][string]$Message
    )

    $color = switch ($Type) {
        'INFO' { 'Cyan' }
        'OK'   { 'Green' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
    }

    Write-Host (('[{0,-4}] {1}' -f $Type, $Message)) -ForegroundColor $color
}

function Test-IsAdministrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-TargetAdapter {
    $allAdapters = @(Get-NetAdapter -IncludeHidden -ErrorAction Stop)

    if (-not $IncludeVirtual) {
        $allAdapters = @($allAdapters | Where-Object { $_.Virtual -eq $false })
    }

    $selected = foreach ($pattern in $AdapterName) {
        $allAdapters | Where-Object { $_.Name -like $pattern }
    }

    return @($selected | Sort-Object -Property InterfaceIndex -Unique)
}

function Get-IPv6BindingState {
    param([Parameter(Mandatory)]$Adapter)

    Get-NetAdapterBinding `
        -Name $Adapter.Name `
        -ComponentID 'ms_tcpip6' `
        -ErrorAction Stop
}

try {
    Write-Host ''
    Write-Host 'IPv6 adapter binding manager' -ForegroundColor White
    Write-Host ('=' * 79) -ForegroundColor DarkGray

    if ($Action -ne 'Status' -and -not (Test-IsAdministrator)) {
        throw 'Run PowerShell as Administrator to enable or disable IPv6.'
    }

    $adapters = @(Get-TargetAdapter)
    if ($adapters.Count -eq 0) {
        throw "No adapters matched: $($AdapterName -join ', ')"
    }

    Write-ColorMessage INFO ("Action: {0}; matched adapter(s): {1}" -f $Action, $adapters.Count)
    Write-Host ''

    $results = foreach ($adapter in $adapters) {
        try {
            $binding = Get-IPv6BindingState -Adapter $adapter
            $before  = [bool]$binding.Enabled

            if ($Action -eq 'Status') {
                $resultText = if ($before) { 'Enabled' } else { 'Disabled' }
                Write-ColorMessage INFO ("{0}: IPv6 is {1}" -f $adapter.Name, $resultText)
            }
            else {
                $desiredState = $Action -eq 'Enable'

                if ($before -eq $desiredState) {
                    Write-ColorMessage OK ("{0}: IPv6 is already {1}" -f $adapter.Name, $Action.ToLowerInvariant() + 'd')
                }
                elseif ($PSCmdlet.ShouldProcess($adapter.Name, "$Action IPv6 adapter binding")) {
                    if ($desiredState) {
                        Enable-NetAdapterBinding -Name $adapter.Name -ComponentID 'ms_tcpip6' -Confirm:$false
                    }
                    else {
                        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID 'ms_tcpip6' -Confirm:$false
                    }

                    $after = [bool](Get-IPv6BindingState -Adapter $adapter).Enabled
                    if ($after -ne $desiredState) {
                        throw 'The command completed, but the resulting binding state was not as requested.'
                    }

                    Write-ColorMessage OK ("{0}: IPv6 has been {1}" -f $adapter.Name, $Action.ToLowerInvariant() + 'd')
                }
            }

            $finalBinding = Get-IPv6BindingState -Adapter $adapter
            [pscustomobject]@{
                AdapterName = $adapter.Name
                Description = $adapter.InterfaceDescription
                Status      = $adapter.Status
                IPv6Enabled = [bool]$finalBinding.Enabled
                Result      = 'Success'
            }
        }
        catch {
            Write-ColorMessage FAIL ("{0}: {1}" -f $adapter.Name, $_.Exception.Message)
            [pscustomobject]@{
                AdapterName = $adapter.Name
                Description = $adapter.InterfaceDescription
                Status      = $adapter.Status
                IPv6Enabled = $null
                Result      = $_.Exception.Message
            }
        }
    }

    Write-Host ''
    $results | Format-Table -AutoSize

    if ($results.Result -ne 'Success') {
        exit 1
    }
}
catch {
    Write-ColorMessage FAIL $_.Exception.Message
    exit 1
}
