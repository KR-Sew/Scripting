<#
.SYNOPSIS
  Move DNS records from a subdomain zone into a parent zone.

.DESCRIPTION
  - Exports full backup of both zones
  - Filters only eligible records (A, AAAA, CNAME, MX, TXT, SRV)
  - Recreates them inside the parent zone
  - DRY-RUN mode enabled by default (no changes applied)
  - Logs all operations

.NOTES
  Requires: RSAT DNS Server Tools or running on DNS server
#>

# ===========================
# CONFIGURATION
# ===========================
$OldZone       = "sub.site.com"
$NewZone       = "site.com"
$BackupFolder  = "C:\DNS-Migration"
$ApplyChanges  = $false   # Change to $true once you are ready
$LogFile       = "$BackupFolder\migration.log"

# Eligible record types to migrate
$RecordTypesToMove = @("A", "AAAA", "CNAME", "MX", "TXT", "SRV")

# ===========================
# PREPARE
# ===========================
if (!(Test-Path $BackupFolder)) {
    New-Item -ItemType Directory -Path $BackupFolder | Out-Null
}

"=== DNS Migration Log ($(Get-Date)) ===" | Out-File $LogFile

Write-Host "[INFO] Exporting zones for backup…" -ForegroundColor Cyan
$oldZoneRecords = Get-DnsServerResourceRecord -ZoneName $OldZone
$newZoneRecords = Get-DnsServerResourceRecord -ZoneName $NewZone

$oldZoneRecords | Export-Clixml "$BackupFolder\$OldZone-backup.xml"
$newZoneRecords | Export-Clixml "$BackupFolder\$NewZone-backup.xml"

Add-Content $LogFile "[BACKUP] Exported backups to $BackupFolder"

# ===========================
# FILTER RECORDS TO MOVE
# ===========================
Write-Host "[INFO] Filtering records…" -ForegroundColor Cyan

$recordsToMove = $oldZoneRecords | Where-Object {
    $_.RecordType -in $RecordTypesToMove
}

Write-Host "[INFO] Found $($recordsToMove.Count) movable records." -ForegroundColor Yellow
Add-Content $LogFile "[INFO] Found $($recordsToMove.Count) records to migrate."

# ===========================
# PROCESS EACH RECORD
# ===========================
foreach ($rec in $recordsToMove) {

    # Convert FQDN → host name
    # e.g., smtp.sub.site.com → smtp
    $newHostName = $rec.HostName.Replace("." + $OldZone, "")

    Write-Host "[MOVE] $($rec.HostName) → $newHostName.$NewZone" -ForegroundColor Green
    Add-Content $LogFile "[MOVE] $($rec.HostName) → $newHostName.$NewZone"

    if ($ApplyChanges) {

        # Create the record in the NEW zone
        $newRecord = New-DnsServerResourceRecord `
            -Name $newHostName `
            -RecordData $rec.RecordData `
            -TimeToLive $rec.TimeToLive

        Add-DnsServerResourceRecord -ZoneName $NewZone -InputObject $newRecord -ErrorAction Stop

        # Remove original record
        Remove-DnsServerResourceRecord `
            -ZoneName $OldZone `
            -Name $rec.HostName `
            -RecordData $rec.RecordData `
            -RRType $rec.RecordType `
            -Force -ErrorAction Stop

        Add-Content $LogFile "[APPLIED] Migrated and removed $($rec.HostName)"
    }
    else {
        Add-Content $LogFile "[DRY-RUN] Would migrate $($rec.HostName)"
    }
}

# ===========================
# SUMMARY
# ===========================
if ($ApplyChanges) {
    Write-Host "`n[COMPLETE] Migration applied successfully!" -ForegroundColor Green
    Add-Content $LogFile "[SUMMARY] Migration applied."
}
else {
    Write-Host "`n[DRY-RUN] No changes were applied. Review the log and set ApplyChanges = \$true" -ForegroundColor Yellow
    Add-Content $LogFile "[SUMMARY] DRY-RUN only. No changes applied."
}

Write-Host "Log file: $LogFile"
