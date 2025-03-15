#####################################################################
#  Author:  #
#####################################################################
#
# Скрипт принимает входящие переменные
# $DBName имя каталога в котором харнится бэкап базы данных
# $DBPath путь к папке сбэкапом (без кавычек)
# $Days количество дней, после которых бэкапы подлежат удалениюот текущей даты
# При вызове через xp_cmdshell нужно оборачивать в переменную
# командлет Get-Date  в связи с конфликтом с аналогичным по названию в MS SQL server (начиная с 2017 и новее)
###############################################################################################################
Param (
    [Parameter(Mandatory=$true)]
    [string]$DBName, # Database name
    [string]$DBPath, # Path to database
    [string]$CloudFolder 
)

# Set the default cloud path
$DefaultCloudPath = "myDrive:/backup/dbfolder/"
$Path = "$DBPath\$DBName"
$SyncCloudFolder = "$DefaultCloudPath\$CloudFolder"

# Define Event Log Source
$EventSource = "RcloneBackupScript"
$EventLogName = "Application"

# Ensure Event Log Source Exists
if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
    New-EventLog -LogName $EventLogName -Source $EventSource
}

# Ensure the cloud folder path exists
if (-not (Test-Path $SyncCloudFolder)) { 
    New-Item -ItemType Directory -Path $SyncCloudFolder 
}

# Get files modified in the last day
$Days = -1
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays($Days)
$Files = Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -gt $OldDate } 

foreach ($File in $Files) {
    $rcloneCommand = "rclone copy `"$($File.FullName)`" `"$SyncCloudFolder`" --progress"

    # Log file before copying
    Write-EventLog -LogName $EventLogName -Source $EventSource -EntryType Information -EventId 1004 -Message "Copying file: $($File.FullName) to cloud folder: $SyncCloudFolder"

    # Execute rclone command
    Invoke-Expression $rcloneCommand
}

# Clear variables
Clear-Variable DBName, DBPath, Path, OldDate, CurrentDate, Days, SyncCloudFolder, Files
