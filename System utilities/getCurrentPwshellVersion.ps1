Write-Host "There is the current version of PowerShell is :"
$PSVersionTable.PSVersion
Get-Command powershell | Select-Object Version
Get-Host | Select-Object Version