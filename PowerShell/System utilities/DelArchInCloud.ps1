#####################################################################
#  Author  #
#####################################################################
#
# Скрипт принимает входящие переменные
# $DBName имя каталога в котором харнится бэкап базы данных
# $DBPath путь к папке сбэкапом (без кавычек)
# $Days количество дней, после которых бэкапы подлежат удалениюот текущей даты
# При вызове через xp_cmdshell нужно оборачивать в переменную
# командлет Get-Date  в связи с конфликтом с аналогичным по названию в MS QL server (начиная с 2017 и новее)
###############################################################################################################

Param ( [string]$DBPath, [string]$Days )
# $Path = "$DBPath\$SubFolder"
# $Path = "E:\SyncBackup"
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays($Days)
Get-ChildItem -Path $Path -Recurse | Where-Object { $_.LastWriteTime -lt $OldDate } | Remove-Item -Recurse
# Clear-Variable DBName,DBPath,Path,OldDate,CurrentDate,Days