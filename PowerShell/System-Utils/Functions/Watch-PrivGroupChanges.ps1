function Watch-PrivilegedGroupChanges {
<#
.SYNOPSIS
    Monitors privileged group membership changes in the Security event log, sends email alerts, and logs results.

.DESCRIPTION
    This function:
    - Checks the Security log for Event IDs 4728 and 4729.
    - Keeps track of last processed RecordId per Event ID.
    - Sends email alerts for each new event.
    - Logs to text, CSV, and JSON files.

.PARAMETER SmtpServer
    SMTP server for email alerts.

.PARAMETER FromEmail
    Sender email address.

.PARAMETER ToEmail
    Recipient email address.

.PARAMETER LogDirectory
    Directory where log files and the tracking file will be stored.

.PARAMETER CsvLogFile
    Path to the CSV log file.

.PARAMETER JsonLogFile
    Path to the JSON log file.

.EXAMPLE
    Monitor-PrivilegedGroupChanges -SmtpServer "smtp.example.com" -FromEmail "audit@example.com" -ToEmail "admin@example.com" -LogDirectory "C:\Scripts\PrivLogs" -CsvLogFile "C:\Scripts\PrivLogs\Events.csv" -JsonLogFile "C:\Scripts\PrivLogs\Events.json"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$SmtpServer,

    [Parameter(Mandatory)]
    [string]$FromEmail,

    [Parameter(Mandatory)]
    [string]$ToEmail,

    [Parameter(Mandatory)]
    [string]$LogDirectory,

    [Parameter(Mandatory)]
    [string]$CsvLogFile,

    [Parameter(Mandatory)]
    [string]$JsonLogFile
)

$EventLogName = "Security"
$EventIds = @(4728,4729)
$TrackingFile = Join-Path $LogDirectory "LastRecords.json"
$PlainTextLog = Join-Path $LogDirectory "PrivGroupChangeLog.txt"

# Ensure log directory exists
if (-not (Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

# Initialize tracking
if (Test-Path $TrackingFile) {
    $LastRecords = Get-Content $TrackingFile -Raw | ConvertFrom-Json
} else {
    $LastRecords = @{}
    foreach ($id in $EventIds) {
        $LastRecords["$id"] = 0
    }
}

# Collect all events for relevant IDs
$AllEvents = @()

foreach ($EventId in $EventIds) {
    try {
        $lastRecordId = $LastRecords["$EventId"]
        $events = Get-WinEvent -FilterHashtable @{
            LogName = $EventLogName
            Id = $EventId
            StartTime = (Get-Date).AddMinutes(-10)
        } | Where-Object { $_.RecordId -gt $lastRecordId } | Sort-Object RecordId

        if ($events) {
            $AllEvents += $events
        }
    } catch {
        Write-Warning "Error fetching events for ID ${EventId}: $_"
    }
}

if (-not $AllEvents) {
    Write-Host "No new events found."
    return
}

# Process each event
foreach ($evt in $AllEvents) {
    try {
        [xml]$evtXml = $evt.ToXml()
        $data = $evtXml.Event.EventData.Data

        $targetUser   = $data[0]."#text"
        $groupName    = $data[1]."#text"
        $callerDomain = $data[3]."#text"
        $callerUser   = $data[4]."#text"
        $time         = $evt.TimeCreated
        $recordId     = $evt.RecordId
        $eventId      = $evt.Id

        $action = switch ($eventId) {
            4728 { "added to" }
            4729 { "removed from" }
            default { "changed membership in" }
        }

        $timestamp = $time.ToString("yyyy-MM-dd HH:mm:ss")
        $msg = "[{0}] {1}\{2} {3} '{4}' group (target user: {5}) [EventID: {6}, RecordID: {7}]" -f `
            $timestamp, $callerDomain, $callerUser, $action, $groupName, $targetUser, $eventId, $recordId

        Write-Output $msg
        Add-Content -Path $PlainTextLog -Value $msg

        # Email alert with safe variable interpolation
        $body = @"
Event Time: $timestamp
Action: $($callerDomain)\$($callerUser) $action '$groupName'
Target User: $targetUser
EventID: $eventId
RecordID: $recordId
"@

        Send-MailMessage -SmtpServer $SmtpServer -From $FromEmail -To $ToEmail -Subject "Privileged Group Change Detected - $groupName" -Body $body

        # CSV log
        $csvObject = [PSCustomObject]@{
            Timestamp    = $timestamp
            CallerDomain = $callerDomain
            CallerUser   = $callerUser
            Action       = $action
            GroupName    = $groupName
            TargetUser   = $targetUser
            EventID      = $eventId
            RecordID     = $recordId
        }
        $csvLine = ($csvObject | ConvertTo-Csv -NoTypeInformation)[1]
        Add-Content -Path $CsvLogFile -Value $csvLine

        # JSON log
        $jsonObject = @{
            Timestamp    = $timestamp
            CallerDomain = $callerDomain
            CallerUser   = $callerUser
            Action       = $action
            GroupName    = $groupName
            TargetUser   = $targetUser
            EventID      = $eventId
            RecordID     = $recordId
        }
        Add-Content -Path $JsonLogFile -Value ($jsonObject | ConvertTo-Json)

        # Update tracking
        $LastRecords["$eventId"] = $recordId
    }
    catch {
        Write-Warning "Error processing event RecordID $($evt.RecordId): $_"
    }
}

# Save updated tracking file
$LastRecords | ConvertTo-Json | Set-Content -Path $TrackingFile -Encoding UTF8

Write-Host "Processing complete. Logs updated and emails sent."
}
