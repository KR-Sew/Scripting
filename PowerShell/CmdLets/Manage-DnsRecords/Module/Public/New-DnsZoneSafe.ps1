function New-DnsZoneSafe {
<#
.SYNOPSIS
Safely creates a file-backed or AD-integrated primary DNS zone.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$ZoneName,
        [ValidateSet('File','ADDomain','ADForest')][string]$ZoneStorage = 'File',
        [string]$ZoneFile,
        [string]$ComputerName = $env:COMPUTERNAME,
        [ValidateSet('None','Secure','NonsecureAndSecure')][string]$DynamicUpdate
    )

    if (-not (Get-Module -ListAvailable DnsServer)) { throw "DnsServer PowerShell module is not installed." }
    Import-Module DnsServer -ErrorAction Stop

    $existing = Get-DnsServerZone -ComputerName $ComputerName -Name $ZoneName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-DnsToolMessage WARN "Zone '$ZoneName' already exists. No change made."
        return $existing
    }

    if (-not $PSCmdlet.ShouldProcess("$ZoneName on $ComputerName", "Create $ZoneStorage DNS zone")) { return }

    switch ($ZoneStorage) {
        'File' {
            if (-not $ZoneFile) { $ZoneFile = "$ZoneName.dns" }
            if (-not $DynamicUpdate) { $DynamicUpdate = 'None' }
            Add-DnsServerPrimaryZone -ComputerName $ComputerName -Name $ZoneName -ZoneFile $ZoneFile -DynamicUpdate $DynamicUpdate -ErrorAction Stop | Out-Null
        }
        'ADDomain' {
            if (-not $DynamicUpdate) { $DynamicUpdate = 'Secure' }
            Add-DnsServerPrimaryZone -ComputerName $ComputerName -Name $ZoneName -ReplicationScope Domain -DynamicUpdate $DynamicUpdate -ErrorAction Stop | Out-Null
        }
        'ADForest' {
            if (-not $DynamicUpdate) { $DynamicUpdate = 'Secure' }
            Add-DnsServerPrimaryZone -ComputerName $ComputerName -Name $ZoneName -ReplicationScope Forest -DynamicUpdate $DynamicUpdate -ErrorAction Stop | Out-Null
        }
    }

    $created = Get-DnsServerZone -ComputerName $ComputerName -Name $ZoneName -ErrorAction Stop
    Write-DnsToolMessage OK "Created '$ZoneName'. Type: $($created.ZoneType); AD integrated: $($created.IsDsIntegrated); Dynamic update: $($created.DynamicUpdate)"
    $created
}
