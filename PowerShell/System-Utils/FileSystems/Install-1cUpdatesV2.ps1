# Improved PowerShell Script for Extracting and Installing Archives

# CONFIGURATION
$archiveDir = "D:\tmp\Update"
$extractDir = "D:\tmp\Update\ext"
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Validate 7-Zip presence
if (-Not (Test-Path -Path $sevenZipPath)) {
    Write-Error "7-Zip executable not found at '$sevenZipPath'. Exiting."
    exit 1
}

# Create extraction directory if needed
if (-Not (Test-Path -Path $extractDir)) {
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
}

# Get all ZIP files
$archiveFiles = Get-ChildItem -Path $archiveDir -Filter *.zip

if ($archiveFiles.Count -eq 0) {
    Write-Host "No archives found in '$archiveDir'. Nothing to do."
    exit 0
}

foreach ($archive in $archiveFiles) {
    Write-Host "Processing archive: $($archive.Name)" -ForegroundColor Cyan

    # Clean up previous extraction
    Get-ChildItem -Path $extractDir -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    # Extract archive
    $extractCommand = @(
        "x"
        "`"$($archive.FullName)`""
        "-o`"$extractDir`""
        "*"
        "-y"
    )

    Write-Host "Extracting to '$extractDir'..."
    $process = Start-Process -FilePath $sevenZipPath -ArgumentList $extractCommand -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Warning "Extraction failed for '$($archive.Name)' with exit code $($process.ExitCode). Skipping."
        continue
    }

    # Find setup executables
    $setupFiles = Get-ChildItem -Path $extractDir -Filter "setup.exe" -Recurse

    if ($setupFiles.Count -eq 0) {
        Write-Warning "No setup.exe found in '$($archive.Name)'."
        continue
    }

    foreach ($setup in $setupFiles) {
        Write-Host "Running installer '$($setup.FullName)' silently..."
        try {
            $installerProcess = Start-Process -FilePath $setup.FullName -ArgumentList "/s" -Wait -PassThru
            if ($installerProcess.ExitCode -ne 0) {
                Write-Warning "Installer '$($setup.Name)' exited with code $($installerProcess.ExitCode)."
            } else {
                Write-Host "Installation completed successfully for '$($setup.Name)'."
            }
        }
        catch {
            Write-Error "Failed to run installer: $_"
        }
    }
}

Write-Host "All archives processed."
