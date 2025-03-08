# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Output "PowerShell 5.0 or higher is required. Exiting."
    exit 1
}

# Check the installed version of GitHub CLI
$installedVersion = gh --version 2>$null
if (-not $installedVersion) {
    Write-Output "GitHub CLI is not installed. Please install it first."
    exit 1
}

# Extract only the version number (e.g., "2.46.0" from "gh version 2.46.0 (2024-02-02)")
$installedVersion = ($installedVersion -match "(\d+\.\d+\.\d+)") ? $matches[1] : $null
Write-Output "Installed version: $installedVersion"

# Define the GitHub API releases URL
$githubReleasesUrl = "https://api.github.com/repos/cli/cli/releases/latest"

# Get the latest release information with error handling
try {
    $latestRelease = Invoke-RestMethod -Uri $githubReleasesUrl -Headers @{ "User-Agent" = "PowerShell" }
} catch {
    Write-Output "Error fetching release information from GitHub. Check your internet connection."
    exit 1
}

# Extract the latest version number (removing the "v" prefix)
$latestVersion = $latestRelease.tag_name -replace "^v", ""
Write-Output "Latest version: $latestVersion"

# Compare installed version with the latest version
if ($installedVersion -eq $latestVersion) {
    Write-Output "You are using the latest version of GitHub CLI."
    exit 0
}

# Prompt the user for update
$userInput = Read-Host "A new version ($latestVersion) is available. Would you like to update? (yes/no)"

if ($userInput.ToLower() -eq "yes") {
    # Find the Windows x64 MSI asset
    $msiAsset = $latestRelease.assets | Where-Object { $_.name -like "*windows_amd64.msi" }
    
    if (-not $msiAsset) {
        Write-Output "Error: Could not find the Windows MSI installer for GitHub CLI."
        exit 1
    }

    $downloadUrl = $msiAsset.browser_download_url
    $installerPath = "$env:TEMP\gh_$latestVersion.msi"

    # Download the installer with error handling
    Write-Output "Downloading GitHub CLI $latestVersion..."
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -ErrorAction Stop
    } catch {
        Write-Output "Error downloading the installer. Check your internet connection."
        exit 1
    }

    # Install the downloaded package
    Write-Output "Installing GitHub CLI..."
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

    # Clean up the installer file
    Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue

    Write-Output "GitHub CLI has been successfully updated to version $latestVersion."
} elseif ($userInput.ToLower() -eq "no") {
    Write-Output "Update canceled. Exiting script."
} else {
    Write-Output "Invalid input. Please enter 'yes' or 'no'."
}
