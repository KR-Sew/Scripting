#####################################################################
#  Author  #
#####################################################################
#
# Скрипт принимает входящие переменные
# 
# $DBFolder имя каталога в котором харнится бэкап базы данных
# $DBSrcFdr путь к каталогу с бэкапами (без кавычек) из которой копируем
# $DBArchFdr путь к каталогу с архивами в который копируем
#  
# При вызове через xp_cmdshell нужно оборачивать в переменную
# командлет Get-Date  в связи с конфликтом с аналогичным по названию в MS QL server (начиная с 2017 и новее)
###############################################################################################################
Param ( 
    [string]$DBFolder, 
    [string]$DBSrcFdr, 
    [string]$DBArchFdr 
)

$SrcFdr = "$DBSrcFdr\$DBFolder"      
$d = Get-Date 
$timeStamp = $d.ToString('dd.MM')
$ArchFdr = "$DBArchFdr\$DBFolder\$timeStamp"

# Define Event Log Source
$EventSource = "FileMoveScript"
$EventLogName = "Application"

# Ensure Event Log Source Exists
if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
    New-EventLog -LogName $EventLogName -Source $EventSource
}

# Create archive folder if it doesn't exist
if (-not (Test-Path -Path $ArchFdr)) { 
    New-Item -ItemType Directory -Path $ArchFdr
}

# Move files and log the operation
Get-ChildItem $SrcFdr -Recurse | ForEach-Object {
    # Log before moving the file
    Write-EventLog -LogName $EventLogName -Source $EventSource -EntryType Information -EventId 1002 -Message "Moving file: $($_.FullName) to $ArchFdr"

    # Move the file
    Move-Item -Path $_.FullName -Destination $ArchFdr -Force
}

# Clear variables
Clear-Variable SrcFdr, ArchFdr, DBFolder, DBSrcFdr, DBArchFdr
