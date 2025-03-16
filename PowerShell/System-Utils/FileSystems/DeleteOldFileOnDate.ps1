#####################################################################
#  Author Карасёв Андрей @gmail.com create date 27.05.2021 #
#####################################################################
#
# Скрипт принимает входящие переменные
# $DBName имя каталога в котором харнится бэкап базы данных
# $DBPath путь к папке сбэкапом (без кавычек)
# $Days количество дней, после которых бэкапы подлежат удалениюот текущей даты
# При вызове через xp_cmdshell нужно оборачивать в переменную
# командлет Get-Date  в связи с конфликтом с аналогичным по названию в MS QL server (начиная с 2017 и новее)
###############################################################################################################
# Paremeters: -DBPath the path to database files
#             -DBName the database name
#             -Days the amount of days after which backups should be deleted from the current date
Param ( 
    [Parameter(Mandatory=$true)]
    [string]$DBPath, 
    [int]$Days,
    [string]$DBName
)

$Path = "$DBPath\$DBName"
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays(-$Days)

# Define Event Log Source
$EventSource = "FileCleanupScript"
$EventLogName = "Application"

# Ensure Event Log Source Exists
if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
    New-EventLog -LogName $EventLogName -Source $EventSource
}

# Get and delete old files while logging
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $OldDate } | ForEach-Object {
    # Log file before deletion
    Write-EventLog -LogName $EventLogName -Source $EventSource -EntryType Information -EventId 1001 -Message "Deleting file: $($_.FullName)"

    # Delete the file/folder
    Remove-Item $_.FullName -Recurse -Force
}

# Clear variables
Clear-Variable DBName,DBPath,Path,OldDate,CurrentDate,Days
