Param (
    [Parameter(Mandatory=$True)]
    [string]$startTime, # start time to seek like "13-05-2025 19:27:16"
    [Parameter(Mandatory=$True)]
    [string]$endTime, # end of time to seek like "13-05-2025 20:27:16"
    [Parameter(Mandatory=$True)]
    [Int64[]]$id # the massive of ID numbers in EventLog like 4728,4729 (create or delete users in AD)
)
$startTime = Get-Date ($startTime)
$endTime = Get-Date ($endTime)


$events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$id; StartTime=$startTime; EndTime=$endTime}


foreach ($event in $events) {
    $event | Format-List -Property TimeCreated, Id, Message
    Write-Host "-----------------------------------" 
}
