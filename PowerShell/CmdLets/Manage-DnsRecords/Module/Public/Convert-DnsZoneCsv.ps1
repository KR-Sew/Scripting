function Convert-DnsZoneCsv {
<#
.SYNOPSIS
Safely replaces a DNS domain string in an exported DNS CSV without Excel rewriting the CSV format.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$OldDomain,
        [Parameter(Mandatory)][string]$NewDomain,
        [Parameter(Mandatory)][string]$OutputPath
    )

    if (-not (Test-Path $Path -PathType Leaf)) { throw "CSV file '$Path' does not exist." }
    $records = @(Import-Csv -Path $Path -Delimiter ',' -ErrorAction Stop)
    if (-not $records) { throw 'CSV contains no records.' }

    $required = 'HostName','RecordType','TTL','Data'
    $columns = @($records[0].PSObject.Properties.Name)
    $missing = @($required | Where-Object { $_ -notin $columns })
    if ($missing) { throw "Invalid CSV structure. Missing columns: $($missing -join ', ')" }

    $pattern = [regex]::Escape($OldDomain)
    $converted = @(
        foreach ($r in $records) {
            [pscustomobject][ordered]@{
                HostName   = $r.HostName
                RecordType = $r.RecordType
                TTL        = $r.TTL
                Data       = ([string]$r.Data -replace $pattern, $NewDomain)
            }
        }
    )
    $parent = Split-Path -Parent $OutputPath
    if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    $converted | Export-Csv -Path $OutputPath -Delimiter ',' -NoTypeInformation -Encoding utf8 -Force
    Write-DnsToolMessage OK "Created '$OutputPath' with $($converted.Count) record(s)."
    $converted
}
