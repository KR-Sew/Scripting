<#
.SYNOPSIS
    Imports DNS records from a CSV file into an existing Windows DNS zone.

.CSV FORMAT
    HostName,RecordType,TTL,Data

.EXAMPLE
    .\Import-DnsZone.ps1 `
        -ZoneName "domainzone.name" `
        -CsvFile "C:\DNS\records.csv"

.EXAMPLE
    .\Import-DnsZone.ps1 `
        -ZoneName "domainzone.name" `
        -CsvFile "C:\DNS\records.csv" `
        -ComputerName "dns01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ZoneName,

    [Parameter(Mandatory)]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Leaf)) {
            throw "CSV file '$_' does not exist."
        }

        $true
    })]
    [string]$CsvFile,

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
# Counters
# ============================================================

$Imported = 0
$Skipped  = 0
$Failed   = 0


# ============================================================
# Header
# ============================================================

Write-Host ""
Write-Host "DNS CSV Import" -ForegroundColor White
Write-Host "===============================================================================" -ForegroundColor DarkGray

Write-Host "DNS server : " -NoNewline
Write-Host $ComputerName -ForegroundColor Yellow

Write-Host "DNS zone   : " -NoNewline
Write-Host $ZoneName -ForegroundColor Yellow

Write-Host "CSV file   : " -NoNewline
Write-Host $CsvFile -ForegroundColor Yellow

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
# Check destination zone
# ============================================================

Write-Info "Checking DNS zone '$ZoneName'..."

try {

    $Zone = Get-DnsServerZone `
        -ComputerName $ComputerName `
        -Name $ZoneName `
        -ErrorAction Stop

    Write-OK "DNS zone exists."
}
catch {

    Write-Warn "DNS zone '$ZoneName' does not exist on '$ComputerName'."

    Write-Host ""
    $Answer = Read-Host "Do you want to create primary zone '$ZoneName'? [Y/N]"

    if ($Answer -match '^[Yy]$') {

        $ZoneFile = "$ZoneName.dns"

        Write-Info "Creating primary DNS zone '$ZoneName'..."

        try {

            Add-DnsServerPrimaryZone `
                -ComputerName $ComputerName `
                -Name $ZoneName `
                -ZoneFile $ZoneFile `
                -DynamicUpdate None `
                -ErrorAction Stop

            Write-OK "DNS zone '$ZoneName' successfully created."
            Write-Info "Zone file: $ZoneFile"
        }
        catch {

            Write-Fail "Failed to create DNS zone '$ZoneName'."
            Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed

            exit 1
        }
    }
    else {

        Write-Warn "DNS zone creation cancelled."
        Write-Info "No records were imported."

        exit 0
    }
}

# ============================================================
# Load CSV
# ============================================================

try {

    $Records = @(Import-Csv -Path $CsvFile -ErrorAction Stop)
    # ============================================================
    # Validate CSV structure
    # ============================================================

      $RequiredColumns = @(
                  "HostName",
                  "RecordType",
                  "TTL",
                 "Data"
                 )

      $CsvColumns = @(
          $Records[0].PSObject.Properties.Name
          )

      $MissingColumns = @(
              $RequiredColumns | Where-Object {
            $_ -notin $CsvColumns
           }
          )

      if ($MissingColumns.Count -gt 0) {

          Write-Fail "Invalid CSV structure."

          Write-Host ""
          Write-Host "Required columns:"
          Write-Host "  HostName, RecordType, TTL, Data"

          Write-Host ""
          Write-Host "Detected columns:"
    
       foreach ($Column in $CsvColumns) {
                Write-Host "  $Column"
       }

       Write-Host ""
       Write-Fail "Missing column(s): $($MissingColumns -join ', ')"

        exit 1
       }

    Write-OK "Loaded $($Records.Count) record(s) from CSV."
}
catch {

    Write-Fail "Could not read CSV file."
    Write-Host $_.Exception.Message

    exit 1
}


if ($Records.Count -eq 0) {
    Write-Fail "CSV file contains no records."
    exit 1
}


# ============================================================
# Import
# ============================================================

Write-Host ""
Write-Host "Importing records" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor DarkGray


foreach ($Record in $Records) {

    $Name = $Record.HostName.Trim()
    $Type = $Record.RecordType.Trim().ToUpper()
    $Data = $Record.Data.Trim()

    try {

        $TTL = [TimeSpan]::FromSeconds(
            [int]$Record.TTL
        )
    }
    catch {

        Write-Fail "$Type $Name - Invalid TTL '$($Record.TTL)'"

        $Failed++
        continue
    }

    # ============================================================
    # Check if record already exists
    # ============================================================

            $ExistingRecord = Get-DnsServerResourceRecord `
                -ComputerName $ComputerName `
                -ZoneName $ZoneName `
                -Name $Name `
                -RRType $Type `
                -ErrorAction SilentlyContinue

            if ($ExistingRecord) {

                Write-Warn ("{0,-6} {1} - already exists, skipped" -f $Type, $Name)

                $Skipped++
                continue
             }            





    try {

        switch ($Type) {

            # =================================================
            # A
            # =================================================

            "A" {

                Add-DnsServerResourceRecordA `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -IPv4Address $Data `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # AAAA
            # =================================================

            "AAAA" {

                Add-DnsServerResourceRecordAAAA `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -IPv6Address $Data `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # CNAME
            # =================================================

            "CNAME" {

                Add-DnsServerResourceRecordCName `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -HostNameAlias $Data `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # MX
            #
            # Example Data:
            #
            # 10;mail.lightcyber.one.
            # =================================================

            "MX" {

                $Preference, $MailExchange = $Data -split ";", 2

                Add-DnsServerResourceRecordMX `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -Preference ([UInt16]$Preference) `
                    -MailExchange $MailExchange `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # TXT
            # =================================================

            "TXT" {

                Add-DnsServerResourceRecord `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -Txt `
                    -DescriptiveText $Data `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # SRV
            #
            # Example Data:
            #
            # 0;10;443;server.lightcyber.one.
            # =================================================

            "SRV" {

                $Priority,
                $Weight,
                $Port,
                $Target = $Data -split ";", 4

                Add-DnsServerResourceRecord `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -Srv `
                    -Priority ([UInt16]$Priority) `
                    -Weight ([UInt16]$Weight) `
                    -Port ([UInt16]$Port) `
                    -DomainName $Target `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
                 }


            # =================================================
            # NS
            # =================================================

            "NS" {

                Add-DnsServerResourceRecord `
                    -ComputerName $ComputerName `
                    -ZoneName $ZoneName `
                    -Name $Name `
                    -NS `
                    -NameServer $Data `
                    -TimeToLive $TTL `
                    -ErrorAction Stop
            }


            # =================================================
            # Skip SOA
            # =================================================

            "SOA" {

                Write-Warn "SOA $Name - skipped"

                $Skipped++
                continue
            }


            # =================================================
            # Unknown type
            # =================================================

            default {

                Write-Warn "$Type $Name - unsupported record type"

                $Skipped++
                continue
            }
        }


        Write-OK ("{0,-6} {1}" -f $Type, $Name)

        $Imported++
    }
    catch {

        Write-Fail ("{0,-6} {1}" -f $Type, $Name)

        Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed

        $Failed++
    }
}


# ============================================================
# Result
# ============================================================

Write-Host ""
Write-Host "Import result" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor DarkGray

Write-Host "CSV records : $($Records.Count)"

Write-Host "Imported    : " -NoNewline
Write-Host $Imported -ForegroundColor Green

Write-Host "Skipped     : " -NoNewline
Write-Host $Skipped -ForegroundColor Yellow

Write-Host "Failed      : " -NoNewline

if ($Failed -eq 0) {
    Write-Host $Failed -ForegroundColor Green
}
else {
    Write-Host $Failed -ForegroundColor Red
}


if ($Failed -gt 0) {

    Write-Host ""
    Write-Fail "Import completed with errors."

    exit 1
}


Write-Host ""
Write-OK "Import completed successfully."