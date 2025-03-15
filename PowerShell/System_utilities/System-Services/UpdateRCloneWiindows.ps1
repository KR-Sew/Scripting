# Define parameters
param (
    [string]$SourceFolder = "C:\path\to\your\rclone\config",  # Change this to your rclone config path
    [string]$RcloneDownloadUrl = "https://downloads.rclone.org/rclone-current-windows-amd64.zip",
    [string]$RcloneInstallPath = "C:\Program Files\rclone"  # Change this to your rclone install path
)

# Define temporary file paths
$tempZipPath = "$env:TEMP\rclone.zip"
$tempExtractPath = "$env:TEMP\rclone"

# Download the latest rclone
Write-Host "Downloading rclone..."
Invoke-WebRequest -Uri $RcloneDownloadUrl -OutFile $tempZipPath

# Create a temporary directory for extraction
Write-Host "Extracting rclone..."
Expand-Archive -Path $tempZipPath -DestinationPath $tempExtractPath -Force

# Stop any running rclone processes (optional)
Get-Process rclone -ErrorAction SilentlyContinue | Stop-Process -Force

# Replace the old rclone executable with the new one
Write-Host "Updating rclone..."
Copy-Item -Path "$tempExtractPath\rclone.exe" -Destination "$RcloneInstallPath\rclone.exe" -Force

# Clean up temporary files
Remove-Item -Path $tempZipPath -Force
Remove-Item -Path $tempExtractPath -Recurse -Force

Write-Host "rclone has been updated successfully."
