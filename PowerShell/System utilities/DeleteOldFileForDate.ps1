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
#$Days = "-10"
$CurrentDate = Get-Date
$OldDate = $CurrentDate.AddDays($Days)
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $OldDate } | Remove-Item -Recurse
Clear-Variable DBName,DBPath,Path,OldDate,CurrentDate,Days