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

Param ( [string]$DBFolder , [string]$DBSrcFdr, [string]$DBArchFdr )
$SrcFdr="$DBSrcFdr\$DBFolder"      
$d = Get-Date 
$timeStamp= $d.AddDays(0).ToString('dd.MM')
If (-not (Test-Path -Path "$DBArchFdr\$DBFolder\$timeStamp")) { New-Item -ItemType Directory -Path "$DBArchFdr\$DBFolder\$timeStamp" } 
$ArchFdr= "$DBArchFdr\$DBFolder\$timeStamp"   
 Get-ChildItem $SrcFdr -Recurse | Move-Item -Destination $ArchFdr
Clear-Variable SrcFdr,ArchFdr,DBFolder,DBSrcFdr,DBArchFdr