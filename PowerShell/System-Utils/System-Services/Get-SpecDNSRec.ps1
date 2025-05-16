# Get-DnsRecords.ps1
# Queries specific types of DNS records for a given hostname or domain

param (
    [Parameter(Mandatory = $true)]
    [string]$Target,

    [Parameter(Mandatory = $true)]
    [ValidateSet("A", "AAAA", "CNAME", "MX", "PTR", "TXT", "NS", "SRV", "SOA")]
    [string[]]$RecordTypes,

    [string]$DnsServer = $null  # Optional: use custom DNS server
)

foreach ($type in $RecordTypes) {
    Write-Host "`nResolving [$type] record(s) for: $Target" -ForegroundColor Cyan

    try {
        $results = Resolve-DnsName -Name $Target -Type $type -Server $DnsServer -ErrorAction Stop
        $results | Format-Table Name, Type, TTL, IPAddress, NameHost, MailExchange, Preference -AutoSize
    }
    catch {
        Write-Warning "No $type records found or lookup failed for $Target."
    }
}
# Get-DnsRecords.ps1
# Queries specific types of DNS records for a given hostname or domain

param (
    [Parameter(Mandatory = $true)]
    [string]$Target,

    [Parameter(Mandatory = $true)]
    [ValidateSet("A", "AAAA", "CNAME", "MX", "PTR", "TXT", "NS", "SRV", "SOA")]
    [string[]]$RecordTypes,

    [string]$DnsServer = $null  # Optional: use custom DNS server
)

foreach ($type in $RecordTypes) {
    Write-Host "`nResolving [$type] record(s) for: $Target" -ForegroundColor Cyan

    try {
        $results = Resolve-DnsName -Name $Target -Type $type -Server $DnsServer -ErrorAction Stop
        $results | Format-Table Name, Type, TTL, IPAddress, NameHost, MailExchange, Preference -AutoSize
    }
    catch {
        Write-Warning "No $type records found or lookup failed for $Target."
    }
}
