# PowerShell script to update MongoDB Atlas CLI on Windows

$ErrorActionPreference = "Stop"

function Get-LatestAtlasCliVersion {
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/mongodb/mongodb-atlas-cli/releases/latest" -Headers @{ 'User-Agent' = 'PowerShell' }
    return $latestRelease.tag_name.TrimStart("v")
}

function Get-InstalledAtlasCliVersion {
    try {
        $versionOutput = atlas.exe version 2>$null
        if ($versionOutput -match "atlas version (\d+\.\d+\.\d+)") {
            return $matches[1]
        }
    } catch {
        return $null
    }
}

function Update-AtlasCli {
    $latestVersion = Get-LatestAtlasCliVersion
    $installedVersion = Get-InstalledAtlasCliVersion

    Write-Host "Installed version: $installedVersion"
    Write-Host "Latest version:    $latestVersion"

    if ($installedVersion -eq $latestVersion) {
        Write-Host "MongoDB Atlas CLI is already up to date." -ForegroundColor Green
        return
    }

    Write-Host "Updating MongoDB Atlas CLI to version $latestVersion..." -ForegroundColor Yellow

    # GitHub URL for downloading the latest release
    $baseUrl = "https://github.com/mongodb/mongodb-atlas-cli/releases/download/v$latestVersion"
    $zipFileName = "atlascli_windows_amd64.zip"

    # Full URL for the download
    $zipUrl = "$baseUrl/$zipFileName"
    Write-Host "Attempting to download from: $zipUrl"

    try {
        $response = Invoke-WebRequest -Uri $zipUrl -OutFile "$env:TEMP\atlascli.zip"
    } catch {
        Write-Error "Failed to download the file. Please check if the URL is correct or if the release exists."
        return
    }

    # Extract the ZIP file
    Expand-Archive -Path "$env:TEMP\atlascli.zip" -DestinationPath "$env:TEMP\atlascli" -Force

    # Find the executable
    $atlasExePath = Get-ChildItem -Path "$env:TEMP\atlascli" -Recurse -Filter atlas.exe | Select-Object -First 1

    if (-not $atlasExePath) {
        Write-Error "Failed to locate atlas.exe in the downloaded archive."
        return
    }

    # Install path for Atlas CLI
    $installPath = "$env:ProgramFiles\MongoDB\AtlasCLI"
    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath | Out-Null
    }

    # Copy the new executable to the install path
    Copy-Item -Path $atlasExePath.FullName -Destination "$installPath\atlas.exe" -Force

    # Optionally, add to PATH if not already present
    if (-not ($env:Path -split ";" | Where-Object { $_ -eq $installPath })) {
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$installPath", [EnvironmentVariableTarget]::Machine)
        Write-Host "Added $installPath to system PATH. You may need to restart your shell or log out and back in." -ForegroundColor Cyan
    }

    Write-Host "MongoDB Atlas CLI updated to version $latestVersion successfully." -ForegroundColor Green

    # Clean up
    Remove-Item -Recurse -Force -Path "$env:TEMP\atlascli"
}

Update-AtlasCli
