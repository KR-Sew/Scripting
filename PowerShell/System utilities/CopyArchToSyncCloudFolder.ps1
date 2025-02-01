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

Param ( [string]$DBName, [string]$DBPath,[string]$SyncCloudFolder )
$Path = "$DBPath\$DBName"
#SyncCloudFolder = "E:\SyncBackup"
$Days = "-1"
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays($Days)
$Files = Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -gt $OldDate } | Copy-Item -Destination $SyncCloudFolder -Recurse -Container 
Clear-Variable DBName,DBPath,Path,OldDate,CurrentDate,Days,SyncCloudFolder,Files