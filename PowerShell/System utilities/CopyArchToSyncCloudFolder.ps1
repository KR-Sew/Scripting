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
  # Set the default value
    $DefaultCloudPath = "myDrive:/backup/dbfolder/"

    $Path = "$DBPath\$DBName"
    $SyncCloudFolder = "$DefaultCloudPath\$CloudFolder"

    # Ensure the path exist
if (-not ( Test-Path $SyncCloudFolder)) { New-Item -ItemType Directory $SyncCloudFolder }

$Days = "-1"
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays($Days)
$Files = Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -gt $OldDate } 

foreach ($Files in $Files) {
    $rcloneCommand = "rclone copy `"$($File.FullName)`" `"$SyncCloudFolder`" --progress"

    Invoke-Expression $rcloneCommand
}


Clear-Variable DBName,DBPath,Path,OldDate,CurrentDate,Days,SyncCloudFolder,Files