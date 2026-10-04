function Export-DnsZoneCsv {
<#
.SYNOPSIS
Exports supported Windows DNS records to a portable comma-delimited CSV.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Alias('SourceZone')][string]$ZoneName,
        [Parameter(Mandatory)][Alias('ExportFile')][string]$Path,
        [string]$ComputerName = $env:COMPUTERNAME
    )

    if (-not (Get-Module -ListAvailable DnsServer)) { throw "DnsServer PowerShell module is not installed." }
    Import-Module DnsServer -ErrorAction Stop

    Write-DnsToolMessage INFO "Checking DNS zone '$ZoneName' on '$ComputerName'..."
    $zone = Get-DnsServerZone -ComputerName $ComputerName -Name $ZoneName -ErrorAction Stop
    Write-DnsToolMessage OK "Zone exists. AD integrated: $($zone.IsDsIntegrated)"

    $records = @(Get-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName -ErrorAction Stop)
    $skipped = 0
    $out = @(
        foreach ($r in $records) {
            if ($r.RecordType -in @('SOA','NS')) { $skipped++; continue }
            $data = switch ($r.RecordType) {
                'A'     { $r.RecordData.IPv4Address.IPAddressToString }
                'AAAA'  { $r.RecordData.IPv6Address.IPAddressToString }
                'CNAME' { $r.RecordData.HostNameAlias.ToString() }
                'MX'    { "$($r.RecordData.Preference);$($r.RecordData.MailExchange)" }
                'TXT'   { $r.RecordData.DescriptiveText -join '|' }
                'SRV'   { "$($r.RecordData.Priority);$($r.RecordData.Weight);$($r.RecordData.Port);$($r.RecordData.DomainName)" }
                default { $skipped++; Write-DnsToolMessage WARN "Unsupported $($r.RecordType) record '$($r.HostName)' skipped."; continue }
            }
            [pscustomobject][ordered]@{
                HostName   = $r.HostName
                RecordType = $r.RecordType
                TTL        = [int]$r.TimeToLive.TotalSeconds
                Data       = $data
            }
        }
    )
    if (-not $out) { throw 'No supported records were found to export.' }

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $out | Export-Csv -Path $Path -Delimiter ',' -NoTypeInformation -Encoding utf8 -Force

    $verify = @(Import-Csv -Path $Path -Delimiter ',' -ErrorAction Stop)
    $required = 'HostName','RecordType','TTL','Data'
    $columns = @($verify[0].PSObject.Properties.Name)
    $missing = @($required | Where-Object { $_ -notin $columns })
    if ($missing) { throw "Export verification failed. Missing columns: $($missing -join ', ')" }

    Write-DnsToolMessage OK "Exported $($out.Count) record(s) to '$Path'. Skipped: $skipped"
    $out
}
