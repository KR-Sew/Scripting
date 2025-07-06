function Install-ZipPackages {
    <#
    .SYNOPSIS
        Extracts ZIP archives and runs their setup.exe installers silently.

    .DESCRIPTION
        For each ZIP file in a specified directory, the function:
        - Extracts it into an extraction directory.
        - Finds all setup.exe files (recursively).
        - Runs them with a silent install argument (/s).
        - Reports success or failure.

    .PARAMETER ArchiveDirectory
        Path containing the ZIP archives.

    .PARAMETER ExtractDirectory
        Path where the archives will be extracted.

    .PARAMETER SevenZipPath
        Full path to the 7-Zip executable.

    .EXAMPLE
        Install-ZipPackages -ArchiveDirectory "D:\tmp\Update" -ExtractDirectory "D:\tmp\Update\ext" -SevenZipPath "C:\Program Files\7-Zip\7z.exe"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ArchiveDirectory,

        [Parameter(Mandatory)]
        [string]$ExtractDirectory,

        [Parameter(Mandatory)]
        [string]$SevenZipPath
    )

    # Validate 7-Zip presence
    if (-Not (Test-Path -Path $SevenZipPath)) {
        Write-Error "7-Zip executable not found at '$SevenZipPath'. Exiting."
        return
    }

    # Create extraction directory if needed
    if (-Not (Test-Path -Path $ExtractDirectory)) {
        New-Item -ItemType Directory -Path $ExtractDirectory -Force | Out-Null
    }

    # Get all ZIP files
    $archiveFiles = Get-ChildItem -Path $ArchiveDirectory -Filter *.zip

    if ($archiveFiles.Count -eq 0) {
        Write-Host "No archives found in '$ArchiveDirectory'. Nothing to do."
        return
    }

    foreach ($archive in $archiveFiles) {
        Write-Host "Processing archive: $($archive.Name)" -ForegroundColor Cyan

        # Clean up previous extraction
        Get-ChildItem -Path $ExtractDirectory -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        # Extract archive
        $extractCommand = @(
            "x"
            "`"$($archive.FullName)`""
            "-o`"$ExtractDirectory`""
            "*"
            "-y"
        )

        Write-Host "Extracting to '$ExtractDirectory'..."
        $process = Start-Process -FilePath $SevenZipPath -ArgumentList $extractCommand -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Warning "Extraction failed for '$($archive.Name)' with exit code $($process.ExitCode). Skipping."
            continue
        }

        # Find setup executables
        $setupFiles = Get-ChildItem -Path $ExtractDirectory -Filter "setup.exe" -Recurse

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
}
