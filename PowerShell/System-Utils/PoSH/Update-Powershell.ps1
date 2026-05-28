# Requires PowerShell 5+ to run properly
function Update-PowerShell {
    $ErrorActionPreference = "Stop"

    Write-Host "Checking current PowerShell version..." -ForegroundColor Cyan
    $currentVersion = $PSVersionTable.PSVersion
    Write-Host "Current version: $currentVersion"

    Write-Host "Fetching latest release from GitHub..." -ForegroundColor Cyan
    $githubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $release = Invoke-RestMethod -Uri $githubApiUrl -UseBasicParsing

    $latestVersion = $release.tag_name.TrimStart("v")
    Write-Host "Latest version available: $latestVersion"

    if ([version]$latestVersion -le $currentVersion) {
        Write-Host "You're already on the latest version!" -ForegroundColor Green
        return
    }

    # Find the latest MSI for your system (x64 only)
    $msiAsset = $release.assets | Where-Object { $_.name -match "win-x64.msi$" }
    if (-not $msiAsset) {
        Write-Error "Could not find MSI installer in latest release."
        return
    }

    $msiUrl = $msiAsset.browser_download_url
    $msiFile = "$env:TEMP\PowerShell-$latestVersion-win-x64.msi"

    Write-Host "Downloading MSI installer..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiFile

    Write-Host "Launching MSI installer (this may prompt for admin rights)..." -ForegroundColor Cyan
    Start-Process "msiexec.exe" -ArgumentList "/i `"$msiFile`" /quiet /norestart" -Wait -Verb RunAs

    Write-Host "PowerShell updated to version $latestVersion. Please restart your terminal." -ForegroundColor Green
}

Update-PowerShell
