$AppName = "PowerrShell"
$AppPath = "C:\Program Files\PowerrShell\7\pwsh.exe"
$ContextMenuName = "Open with PowerShell"
$RegistryKeyPath = "HKCR:\Directory\Background\shell\$AppName"
$CommandKeyPath = "$RegistryKeyPath\command"

# Create the registry entry
New-Item -Path $RegistryKeyPath -Force | Out-Null
Set-ItemProperty -Path $RegistryKeyPath -Name "(Default)" -Value $ContextMenuName
Set-ItemProperty -Path $RegistryKeyPath -Name "Icon" -Value $AppPath

# Add the command to execute
New-Item -Path $CommandKeyPath -Force | Out-Null
Set-ItemProperty -Path $CommandKeyPath -Name "(Default)" -Value "`"$AppPath`" `"%1`""

Write-Host "Shortcut added to the right-click menu!" -ForegroundColor Green
