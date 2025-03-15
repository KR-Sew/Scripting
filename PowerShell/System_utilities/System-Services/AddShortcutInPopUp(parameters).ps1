param (
    [Parameter(Mandatory=$true)]
    [string]$App ,   # Default application name like "Notepad"
    [string]$Path ,  # Default application path like "C:\Windows\System32\notepad.exe"
    [string]$Context = "HKCR:\Directory\Background\shell"  # Registry path for desktop background
)

# Define registry key paths
$RegistryKeyPath = "$Context\$App"
$CommandKeyPath = "$RegistryKeyPath\command"

# Create the registry entry
New-Item -Path $RegistryKeyPath -Force | Out-Null
Set-ItemProperty -Path $RegistryKeyPath -Name "(Default)" -Value "Open $App"
Set-ItemProperty -Path $RegistryKeyPath -Name "Icon" -Value $Path

# Add the command to execute
New-Item -Path $CommandKeyPath -Force | Out-Null
Set-ItemProperty -Path $CommandKeyPath -Name "(Default)" -Value "`"$Path`""

Write-Host "Shortcut for $App added to the right-click menu under 'Desktop Background'!" -ForegroundColor Green
