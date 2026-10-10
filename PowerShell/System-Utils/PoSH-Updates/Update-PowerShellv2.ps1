# Ensure any errors stop the script
$ErrorActionPreference = 'Stop'

# Display current PowerShell version
Write-Host "Checking current PowerShell version..." -ForegroundColor Cyan
$currentVersion = $PSVersionTable.PSVersion
Write-Host "Current version: $currentVersion"

# Fetch the latest release metadata from GitHub
Write-Host "Fetching latest release from GitHub..." -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" -UseBasicParsing
$latestVersion = $release.tag_name.TrimStart('v')
Write-Host "Latest version available: $latestVersion"

# Compare versions
if ([version]$latestVersion -le $currentVersion) {
    Write-Host "You are already on the latest version!" -ForegroundColor Green
    return
}

# Locate the MSI asset for win-x64
$msiAsset = $release.assets | Where-Object { $_.name -match 'win-x64\.msi$' }
if (-not $msiAsset) {
    Write-Error "Could not find MSI installer in the latest release."
    return
}

# Prepare download URL and file path
$msiUrl = $msiAsset.browser_download_url
$msiFile = Join-Path -Path $env:TEMP -ChildPath "PowerShell-$latestVersion-win-x64.msi"

# Download the installer
Write-Host "Downloading MSI installer..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $msiUrl -OutFile $msiFile

# Prepare the installation command
$cmd = "msiexec.exe /i `"$msiFile`" /quiet /norestart"
$taskName = "UpdatePowerShell"

# Clean up any existing scheduled task with this name
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create a new scheduled task to run the installer as SYSTEM
Write-Host "Scheduling update task..." -ForegroundColor Cyan
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $cmd"
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

Write-Host ""
Write-Host "✅ Update scheduled. Please disconnect your session NOW!" -ForegroundColor Yellow
Write-Host "The update will run in approximately 1 minute." -ForegroundColor Yellow
