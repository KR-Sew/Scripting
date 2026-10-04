# =========================
# Export-DnsZones.ps1
# =========================

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SourceZone,

    [Parameter(Mandatory)]
    [string]$ExportFile,

    [string]$ComputerName = $env:COMPUTERNAME
)


# ============================================================
# Output functions
# ============================================================

function Write-Info {
    param([string]$Message)

    Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-OK {
    param([string]$Message)

    Write-Host "[ OK ] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)

    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Fail {
    param([string]$Message)

    Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}


# ============================================================
# Header
# ============================================================

Write-Host ""
Write-Host "DNS CSV Export" -ForegroundColor White
Write-Host "===============================================================================" -ForegroundColor DarkGray

Write-Host "DNS server : " -NoNewline
Write-Host $ComputerName -ForegroundColor Yellow

Write-Host "DNS zone   : " -NoNewline
Write-Host $SourceZone -ForegroundColor Yellow

Write-Host "CSV file   : " -NoNewline
Write-Host $ExportFile -ForegroundColor Yellow

Write-Host ""


# ============================================================
# Check DNS module
# ============================================================

if (-not (Get-Module -ListAvailable -Name DnsServer)) {

    Write-Fail "DnsServer PowerShell module is not installed."
    exit 1
}

Import-Module DnsServer


# ============================================================
# Check source zone
# ============================================================

Write-Info "Checking DNS zone '$SourceZone'..."

try {

    $Zone = Get-DnsServerZone `
        -ComputerName $ComputerName `
        -Name $SourceZone `
        -ErrorAction Stop

    Write-OK "DNS zone exists."

    Write-Host "       Zone type     : $($Zone.ZoneType)"
    Write-Host "       AD integrated : $($Zone.IsDsIntegrated)"
}
catch {

    Write-Fail "DNS zone '$SourceZone' does not exist on '$ComputerName'."
    exit 1
}


# ============================================================
# Read DNS records
# ============================================================

Write-Info "Reading DNS records..."

try {

    $Records = @(
        Get-DnsServerResourceRecord `
            -ComputerName $ComputerName `
            -ZoneName $SourceZone `
            -ErrorAction Stop
    )

    Write-OK "Found $($Records.Count) DNS record(s)."
}
catch {

    Write-Fail "Failed to read DNS records."
    Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed

    exit 1
}


# ============================================================
# Convert records
# ============================================================

$Skipped = 0

$Export = @(
    foreach ($Record in $Records) {

        # ----------------------------------------------------
        # Don't export zone infrastructure records
        # ----------------------------------------------------

        if ($Record.RecordType -in @("SOA", "NS")) {

            $Skipped++
            continue
        }


        # ----------------------------------------------------
        # Convert record data
        # ----------------------------------------------------

        $Data = switch ($Record.RecordType) {

            "A" {
                $Record.RecordData.IPv4Address.IPAddressToString
            }

            "AAAA" {
                $Record.RecordData.IPv6Address.IPAddressToString
            }

            "CNAME" {
                $Record.RecordData.HostNameAlias
            }

            "MX" {
                "$($Record.RecordData.Preference);$($Record.RecordData.MailExchange)"
            }

            "TXT" {
                $Record.RecordData.DescriptiveText -join "|"
            }

            "SRV" {
                "$($Record.RecordData.Priority);$($Record.RecordData.Weight);$($Record.RecordData.Port);$($Record.RecordData.DomainName)"
            }

            default {

                Write-Warn "Unsupported record type '$($Record.RecordType)' for '$($Record.HostName)' - skipped."

                $Skipped++
                continue
            }
        }


        # ----------------------------------------------------
        # Create CSV object
        # ----------------------------------------------------

        [PSCustomObject][ordered]@{
            HostName   = $Record.HostName
            RecordType = $Record.RecordType
            TTL        = [int]$Record.TimeToLive.TotalSeconds
            Data       = $Data
        }
    }
)


# ============================================================
# Check export result
# ============================================================

if ($Export.Count -eq 0) {

    Write-Fail "There are no supported DNS records to export."
    exit 1
}


# ============================================================
# Create destination directory if required
# ============================================================

$ExportDirectory = Split-Path `
    -Path $ExportFile `
    -Parent

if (
    $ExportDirectory -and
    -not (Test-Path $ExportDirectory)
) {

    Write-Info "Creating directory '$ExportDirectory'..."

    New-Item `
        -ItemType Directory `
        -Path $ExportDirectory `
        -Force |
        Out-Null
}


# ============================================================
# Export CSV
#
# IMPORTANT:
#
# Explicitly use comma as delimiter.
#
# Do NOT use:
#
#     -UseCulture
#
# because systems with European/Russian regional settings
# may use semicolon as the CSV delimiter.
# ============================================================

Write-Info "Exporting records..."

try {

    $Export |
        Export-Csv `
            -Path $ExportFile `
            -Delimiter ',' `
            -NoTypeInformation `
            -Encoding UTF8 `
            -Force

    Write-OK "CSV file created."
}
catch {

    Write-Fail "Failed to export CSV file."
    Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed

    exit 1
}


# ============================================================
# Verify generated CSV
# ============================================================

Write-Info "Verifying exported CSV..."

try {

    $TestImport = @(
        Import-Csv `
            -Path $ExportFile `
            -Delimiter ',' `
            -ErrorAction Stop
    )

    $RequiredColumns = @(
        "HostName",
        "RecordType",
        "TTL",
        "Data"
    )

    $CsvColumns = @(
        $TestImport[0].PSObject.Properties.Name
    )

    $MissingColumns = @(
        $RequiredColumns |
            Where-Object { $_ -notin $CsvColumns }
    )

    if ($MissingColumns.Count -gt 0) {

        throw "CSV verification failed. Missing column(s): $($MissingColumns -join ', ')"
    }

    Write-OK "CSV structure verified."
}
catch {

    Write-Fail "Exported CSV failed verification."
    Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed

    exit 1
}


# ============================================================
# Result
# ============================================================

Write-Host ""
Write-Host "Export result" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor DarkGray

Write-Host "DNS records : $($Records.Count)"

Write-Host "Exported    : " -NoNewline
Write-Host $Export.Count -ForegroundColor Green

Write-Host "Skipped     : " -NoNewline
Write-Host $Skipped -ForegroundColor Yellow

Write-Host "CSV file    : $ExportFile"

Write-Host ""
Write-OK "DNS export completed successfully."