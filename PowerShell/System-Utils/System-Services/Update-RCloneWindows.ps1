# Define installation path
$RcloneInstallPath = "C:\Program Files\rclone"

# Define temporary file paths
$tempZipPath = "$env:TEMP\rclone.zip"
$tempExtractPath = "$env:TEMP\rclone"

# Function to get installed rclone version
function Get-RcloneVersion {
    if (Get-Command rclone -ErrorAction SilentlyContinue) {
        $versionOutput = & rclone --version 2>$null
        return ($versionOutput -split "`n")[0] -replace "rclone v", ""  # Extract first line and remove prefix
    }
    return $null
}

# Function to get the rclone config path
function Get-RcloneConfigPath {
    if (Get-Command rclone -ErrorAction SilentlyContinue) {
        $configOutput = & rclone config file 2>$null
        return ($configOutput -split "`n")[1]  # Extract second line
    }
    return $null
}

# Function to get latest rclone version from GitHub
function Get-LatestRcloneVersion {
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/rclone/rclone/releases/latest" -Headers @{ "Accept" = "application/vnd.github.v3+json" }
    return $releaseInfo.tag_name -replace "v", ""  # Remove 'v' prefix
}

# Function to get latest rclone download URL for Windows
function Get-LatestRcloneDownloadUrl {
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/rclone/rclone/releases/latest" -Headers @{ "Accept" = "application/vnd.github.v3+json" }
    foreach ($asset in $releaseInfo.assets) {
        if ($asset.name -match "windows-amd64.zip$") {
            return $asset.browser_download_url
        }
    }
    return $null
}

# Get installed version
$installedVersion = Get-RcloneVersion
Write-Host "Installed rclone version: $installedVersion"

# Get config path
$configPath = Get-RcloneConfigPath
if ($configPath) {
    Write-Host "rclone config file location: $configPath"
} else {
    Write-Host "Could not determine rclone config file location."
}

# Get latest version from GitHub
$latestVersion = Get-LatestRcloneVersion
Write-Host "Latest rclone version: $latestVersion"

# Compare versions
if ($installedVersion -eq $latestVersion) {
    Write-Host "rclone is already up to date."
    exit
}

# If rclone is installed, use selfupdate
if ($installedVersion) {
    Write-Host "Updating rclone using selfupdate..."
    rclone selfupdate
    exit
}

# If rclone is not installed, prompt to install
Write-Host "rclone is not installed. Do you want to install it? (Y/N)"
$response = Read-Host
if ($response -ne "Y") { 
    Write-Host "Installation aborted."
    exit 
}

# Get the latest download URL
$RcloneDownloadUrl = Get-LatestRcloneDownloadUrl
if (-not $RcloneDownloadUrl) {
    Write-Host "Failed to retrieve the latest rclone download URL."
    exit
}

# Download the latest rclone
Write-Host "Downloading rclone..."
Invoke-WebRequest -Uri $RcloneDownloadUrl -OutFile $tempZipPath

# Create a temporary directory for extraction
Write-Host "Extracting rclone..."
Expand-Archive -Path $tempZipPath -DestinationPath $tempExtractPath -Force

# Ensure installation path exists
if (-not (Test-Path $RcloneInstallPath)) {
    New-Item -ItemType Directory -Path $RcloneInstallPath -Force | Out-Null
}

# Find the extracted rclone.exe file
$rcloneExePath = Get-ChildItem -Path $tempExtractPath -Recurse -Filter "rclone.exe" | Select-Object -ExpandProperty FullName -First 1

if (-not $rcloneExePath) {
    Write-Host "Error: rclone.exe not found after extraction."
    exit
}

# Copy rclone to installation path
Write-Host "Installing rclone..."
Copy-Item -Path $rcloneExePath -Destination "$RcloneInstallPath\rclone.exe" -Force

# Add to PATH if needed
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($envPath -notlike "*$RcloneInstallPath*") {
    Write-Host "Adding rclone to system PATH..."
    [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$RcloneInstallPath", "Machine")
}

# Clean up temporary files
Remove-Item -Path $tempZipPath -Force
Remove-Item -Path $tempExtractPath -Recurse -Force

Write-Host "rclone installation/update completed successfully."
