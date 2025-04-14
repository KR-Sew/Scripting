# Parameters with default values
param (
    [string]$archiveDir = "D:\tmp\Update",
    [string]$sevenZipExe = "C:\Program Files\7-Zip\7z.exe"
)

$extractDir = Join-Path $archiveDir "ext"

# Function to display colored messages
function Write-Message {
    param (
        [string]$Message,
        [ValidateSet("Info", "Success", "Error")]
        [string]$Type = "Info"
    )
    $color = switch ($Type) {
        "Info"    { "Cyan" }
        "Success" { "Green" }
        "Error"   { "Red" }
    }
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

# Validate 7-Zip path
if (-not (Test-Path $sevenZipExe)) {
    Write-Message "7-Zip executable not found at: $sevenZipExe" "Error"
    exit 1
}

# Ensure extract directory exists
if (-not (Test-Path $extractDir)) {
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    Write-Message "Created extraction directory: $extractDir" "Info"
}

# Get ZIP files
$archiveFiles = Get-ChildItem -Path $archiveDir -Filter *.zip
if ($archiveFiles.Count -eq 0) {
    Write-Message "No ZIP files found in: $archiveDir" "Error"
    exit 0
}

# Process each ZIP file
foreach ($archive in $archiveFiles) {
    Write-Message "Extracting: $($archive.Name)" "Info"

    & $sevenZipExe x $archive.FullName -o$extractDir * -y | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Write-Message "Failed to extract: $($archive.Name)" "Error"
        continue
    }

    # Search for setup.exe in extracted files
    $setupFiles = Get-ChildItem -Path $extractDir -Filter "setup.exe" -Recurse
    foreach ($setup in $setupFiles) {
        Write-Message "Installing: $($setup.FullName)" "Info"
        try {
            Start-Process -FilePath $setup.FullName -ArgumentList "/s" -Wait -ErrorAction Stop
            Write-Message "Installed: $($setup.Name)" "Success"
        } catch {
            Write-Message "Failed to install: $($setup.Name)" "Error"
        }
    }

    # Optional: clear extraction dir before next run
    Get-ChildItem -Path $extractDir -Recurse | Remove-Item -Force -Recurse
}
