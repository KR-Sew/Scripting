Param (
    [Parameter(Mandatory = $true, HelpMessage = "Start time (e.g., '13-05-2025 19:27:16')")]
    [ValidateScript({ $_ -as [datetime] })]
    [string]$startTime,

    [Parameter(Mandatory = $true, HelpMessage = "End time (e.g., '13-05-2025 20:27:16')")]
    [ValidateScript({ $_ -as [datetime] })]
    [string]$endTime,

    [Parameter(Mandatory = $true, HelpMessage = "Array of Event IDs (e.g., 4728,4729)")]
    [ValidateNotNullOrEmpty()]
    [Int[]]$id
)

try {
    $startTimeDT = Get-Date -Date $startTime
    $endTimeDT = Get-Date -Date $endTime
} catch {
    Write-Error "Invalid date format. Please use 'dd-MM-yyyy HH:mm:ss'."
    exit 1
}

Write-Host "Searching Security logs from $startTimeDT to $endTimeDT for Event ID(s): $($id -join ', ')" -ForegroundColor Cyan

try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = $id
        StartTime = $startTimeDT
        EndTime   = $endTimeDT
    } -ErrorAction Stop
} catch {
    Write-Error "Failed to retrieve events: $_"
    exit 1
}

if ($events.Count -eq 0) {
    Write-Host "No events found for the specified criteria." -ForegroundColor Yellow
} else {
    foreach ($event in $events) {
        Write-Host "TimeCreated : $($event.TimeCreated)"
        Write-Host "Event ID    : $($event.Id)"
        Write-Host "Message     : $($event.Message)"
        Write-Host "-----------------------------------" -ForegroundColor DarkGray
    }
}
