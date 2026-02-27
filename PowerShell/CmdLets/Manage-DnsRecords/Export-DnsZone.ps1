# =========================
# Export-DnsZoneRecords.ps1
# =========================

param(
    [Parameter(Mandatory)]
    [string]$SourceZone,

    [Parameter(Mandatory)]
    [string]$ExportFile
)

Write-Host "[INFO] Exporting DNS records from zone: $SourceZone" -ForegroundColor Cyan

$records = Get-DnsServerResourceRecord -ZoneName $SourceZone

$export = foreach ($r in $records) {

    if ($r.RecordType -in @("SOA", "NS")) { continue }

    $data = switch ($r.RecordType) {
        "A"     { $r.RecordData.IPv4Address.IPAddressToString }
        "AAAA"  { $r.RecordData.IPv6Address }
        "CNAME" { $r.RecordData.HostNameAlias }
        "MX"    { "$($r.RecordData.Preference);$($r.RecordData.MailExchange)" }
        "TXT"   { ($r.RecordData.DescriptiveText -join "|") }
        "SRV"   { "$($r.RecordData.Priority);$($r.RecordData.Weight);$($r.RecordData.Port);$($r.RecordData.DomainName)" }
        default { continue }
    }

    [PSCustomObject]@{
        HostName   = $r.HostName
        RecordType = $r.RecordType
        TTL        = $r.TimeToLive.TotalSeconds
        Data       = $data
    }
}

$export | Export-Csv -NoTypeInformation -Encoding UTF8 $ExportFile

Write-Host "[OK] Export completed: $ExportFile" -ForegroundColor Green
