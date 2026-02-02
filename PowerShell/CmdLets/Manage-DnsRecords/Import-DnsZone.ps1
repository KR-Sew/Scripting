param(
    [Parameter(Mandatory)]
    [string]$ParentZone,

    [Parameter(Mandatory)]
    [string]$SubZoneName,   # vpn, mail, dev

    [Parameter(Mandatory)]
    [string]$ImportFile
)

Write-Host "[INFO] Importing $SubZoneName.* into $ParentZone" -ForegroundColor Cyan

$records = Import-Csv $ImportFile

foreach ($r in $records) {

    # Build new hostname inside parent zone
    if ($r.HostName -eq "@") {
        $newName = $SubZoneName
    }
    else {
        $newName = "$($r.HostName).$SubZoneName"
    }

    try {
        switch ($r.RecordType) {

            "A" {
                Add-DnsServerResourceRecordA `
                    -ZoneName $ParentZone `
                    -Name $newName `
                    -IPv4Address $r.Data `
                    -TimeToLive ([TimeSpan]::FromSeconds($r.TTL)) `
                    -AllowUpdateAny `
                    -ErrorAction Stop
            }

            "CNAME" {
                Add-DnsServerResourceRecordCName `
                    -ZoneName $ParentZone `
                    -Name $newName `
                    -HostNameAlias $r.Data `
                    -TimeToLive ([TimeSpan]::FromSeconds($r.TTL)) `
                    -ErrorAction Stop
            }

            "MX" {
                $pref, $host = $r.Data -split ";"
                Add-DnsServerResourceRecordMX `
                    -ZoneName $ParentZone `
                    -Name $newName `
                    -MailExchange $host `
                    -Preference ([int]$pref) `
                    -TimeToLive ([TimeSpan]::FromSeconds($r.TTL)) `
                    -ErrorAction Stop
            }

            "TXT" {
                $txt = $r.Data -split "\|"
                Add-DnsServerResourceRecord `
                    -ZoneName $ParentZone `
                    -Txt `
                    -Name $newName `
                    -DescriptiveText $txt `
                    -TimeToLive ([TimeSpan]::FromSeconds($r.TTL)) `
                    -ErrorAction Stop
            }

            default {
                Write-Host "[SKIP] $($r.RecordType) $newName" -ForegroundColor Yellow
            }
        }

        Write-Host "[OK] $($r.RecordType) $newName" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] $($r.RecordType) $newName -> $_" -ForegroundColor Red
    }
}

Write-Host "[DONE] $SubZoneName imported into $ParentZone" -ForegroundColor Cyan
