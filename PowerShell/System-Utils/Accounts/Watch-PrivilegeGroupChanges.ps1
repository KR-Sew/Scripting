$eventLogName = "Security"
$eventIds = @(4728, 4729)
$lastRecordFile = "C:\Scripts\LastRecord.txt"
$logFile = "C:\Scripts\PrivGroupChangeLog.txt"

if (!(Test-Path $lastRecordFile)) { Set-Content -Path $lastRecordFile -Value 0 }

$lastRecordId = Get-Content $lastRecordFile | ForEach-Object { [int]$_ }

$events = Get-WinEvent -FilterHashtable @{LogName=$eventLogName; Id=$eventIds; StartTime=(Get-Date).AddMinutes(-5) } |
  Where-Object { $_.RecordId -gt $lastRecordId } |
  Sort-Object RecordId

foreach ($event in $events) {
    [xml]$eventXml = $event.ToXml()
    $data = $eventXml.Event.EventData.Data

    $targetUser = $data[0]."#text"
    $groupName = $data[1]."#text"
    $callerUser = $data[4]."#text"
    $callerDomain = $data[3]."#text"
    $time = $event.TimeCreated
    $recordId = $event.RecordId

    $action = switch ($event.Id) {
        4728 { "added to" }
        4729 { "removed from" }
    }

    $msg = "[{0}] {1}\{2} {3} '{4}' group (target user: {5}) [EventID: {6}, RecordID: {7}]" -f `
        $time, $callerDomain, $callerUser, $action, $groupName, $targetUser, $event.Id, $recordId

    Write-Output $msg
    Add-Content -Path $logFile -Value $msg
    Set-Content -Path $lastRecordFile -Value $recordId
}
