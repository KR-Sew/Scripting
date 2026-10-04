function Import-DnsZoneCsv {
<#
.SYNOPSIS
Imports a validated DNS CSV into an existing or newly-created Windows DNS zone.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$ZoneName,
        [Parameter(Mandatory)][string]$Path,
        [string]$ComputerName = $env:COMPUTERNAME,
        [ValidateSet('Ask','File','ADDomain','ADForest','Quit')][string]$IfZoneMissing = 'Ask'
    )

    if (-not (Test-Path $Path -PathType Leaf)) { throw "CSV file '$Path' does not exist." }
    if (-not (Get-Module -ListAvailable DnsServer)) { throw "DnsServer PowerShell module is not installed." }
    Import-Module DnsServer -ErrorAction Stop

    # Validate CSV BEFORE creating/changing DNS.
    $records = @(Import-Csv -Path $Path -Delimiter ',' -ErrorAction Stop)
    if (-not $records) { throw 'CSV contains no records.' }
    $required = 'HostName','RecordType','TTL','Data'
    $columns = @($records[0].PSObject.Properties.Name)
    $missing = @($required | Where-Object { $_ -notin $columns })
    if ($missing) { throw "Invalid CSV structure. Missing column(s): $($missing -join ', '). Detected: $($columns -join ', ')" }

    Write-DnsToolMessage OK "CSV structure verified. Loaded $($records.Count) record(s)."

    $zone = Get-DnsServerZone -ComputerName $ComputerName -Name $ZoneName -ErrorAction SilentlyContinue
    if (-not $zone) {
        $choice = $IfZoneMissing
        if ($choice -eq 'Ask') {
            Write-DnsToolMessage WARN "Zone '$ZoneName' does not exist on '$ComputerName'."
            Write-Host '  [1] File-based primary zone'
            Write-Host '  [2] AD-integrated, Domain replication'
            Write-Host '  [3] AD-integrated, Forest replication'
            Write-Host '  [Q] Quit'
            $answer = (Read-Host 'Select').Trim().ToUpperInvariant()
            $choice = switch ($answer) { '1' {'File'} '2' {'ADDomain'} '3' {'ADForest'} default {'Quit'} }
        }
        if ($choice -eq 'Quit') { Write-DnsToolMessage WARN 'Import cancelled. No DNS changes made.'; return }
        $zone = New-DnsZoneSafe -ZoneName $ZoneName -ZoneStorage $choice -ComputerName $ComputerName
    }

    $imported = 0; $skipped = 0; $failed = 0
    foreach ($record in $records) {
        $name = ([string]$record.HostName).Trim()
        $type = ([string]$record.RecordType).Trim().ToUpperInvariant()
        $data = ([string]$record.Data).Trim()
        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($type) -or [string]::IsNullOrWhiteSpace($data)) {
            Write-DnsToolMessage FAIL 'Record has an empty HostName, RecordType, or Data value.'; $failed++; continue
        }
        try { $ttl = [TimeSpan]::FromSeconds([int]$record.TTL) } catch { Write-DnsToolMessage FAIL "$type $name - invalid TTL '$($record.TTL)'"; $failed++; continue }

        if ($type -eq 'SOA') { Write-DnsToolMessage WARN "SOA $name - skipped"; $skipped++; continue }
        $existing = @(Get-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -RRType $type -ErrorAction SilentlyContinue)
        if ($existing.Count -gt 0) { Write-DnsToolMessage WARN ("{0,-6} {1} - same name/type already exists, skipped" -f $type,$name); $skipped++; continue }
        if (-not $PSCmdlet.ShouldProcess("$name.$ZoneName", "Create $type DNS record")) { $skipped++; continue }

        try {
            switch ($type) {
                'A'     { Add-DnsServerResourceRecordA -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -IPv4Address $data -TimeToLive $ttl -ErrorAction Stop }
                'AAAA'  { Add-DnsServerResourceRecordAAAA -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -IPv6Address $data -TimeToLive $ttl -ErrorAction Stop }
                'CNAME' { Add-DnsServerResourceRecordCName -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -HostNameAlias $data -TimeToLive $ttl -ErrorAction Stop }
                'MX' {
                    $p = $data -split ';',2; if ($p.Count -ne 2) { throw "Invalid MX Data '$data'. Expected preference;host." }
                    Add-DnsServerResourceRecordMX -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -Preference ([uint16]$p[0]) -MailExchange $p[1] -TimeToLive $ttl -ErrorAction Stop
                }
                'TXT' { Add-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -Txt -DescriptiveText @($data -split '\|') -TimeToLive $ttl -ErrorAction Stop }
                'SRV' {
                    $p = $data -split ';',4; if ($p.Count -ne 4) { throw "Invalid SRV Data '$data'. Expected priority;weight;port;target." }
                    Add-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -Srv -Priority ([uint16]$p[0]) -Weight ([uint16]$p[1]) -Port ([uint16]$p[2]) -DomainName $p[3] -TimeToLive $ttl -ErrorAction Stop
                }
                'NS' { Add-DnsServerResourceRecord -ComputerName $ComputerName -ZoneName $ZoneName -Name $name -NS -NameServer $data -TimeToLive $ttl -ErrorAction Stop }
                default { Write-DnsToolMessage WARN "$type $name - unsupported record type, skipped"; $skipped++; continue }
            }
            Write-DnsToolMessage OK ("{0,-6} {1}" -f $type,$name); $imported++
        } catch {
            Write-DnsToolMessage FAIL ("{0,-6} {1} - {2}" -f $type,$name,$_.Exception.Message); $failed++
        }
    }

    Write-Host ''
    Write-Host 'Import result' -ForegroundColor Cyan
    Write-Host ('=' * 79) -ForegroundColor DarkGray
    Write-Host "CSV records : $($records.Count)"
    Write-Host "Imported    : $imported"
    Write-Host "Skipped     : $skipped"
    Write-Host "Failed      : $failed"

    [pscustomobject]@{ ZoneName=$ZoneName; ComputerName=$ComputerName; CsvRecords=$records.Count; Imported=$imported; Skipped=$skipped; Failed=$failed }
}
