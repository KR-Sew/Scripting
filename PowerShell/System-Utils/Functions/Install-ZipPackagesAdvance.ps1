function Install-ZipPackages {
    <#
    .SYNOPSIS
        Extracts ZIP archives, runs specified installers with custom arguments, logs actions, and cleans up extracted files.

    .DESCRIPTION
        For each ZIP file in the specified directory, the function:
        - Extracts it into an extraction directory.
        - Finds all matching executables recursively.
        - Runs them with provided install arguments.
        - Logs all actions.
        - Cleans up extracted files after installation.

    .PARAMETER ArchiveDirectory
        Path containing the ZIP archives.

    .PARAMETER ExtractDirectory
        Path where the archives will be extracted.

    .PARAMETER SevenZipPath
        Full path to the 7-Zip executable.

    .PARAMETER LogFilePath
        Path to a log file to store detailed logs.

    .PARAMETER ExecutableName
        The name of the executable to run (e.g., 'setup.exe').

    .PARAMETER ExecutableArguments
        Command-line arguments to pass to the executable (e.g., '/silent /norestart').

    .EXAMPLE
        Install-ZipPackages -ArchiveDirectory "D:\tmp\Update" -ExtractDirectory "D:\tmp\Update\ext" -SevenZipPath "C:\Program Files\7-Zip\7z.exe" -LogFilePath "D:\tmp\Update\InstallLog.txt" -ExecutableName "setup.exe" -ExecutableArguments "/s"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ArchiveDirectory,

        [Parameter(Mandatory)]
        [string]$ExtractDirectory,

        [Parameter(Mandatory)]
        [string]$SevenZipPath,

        [Parameter(Mandatory)]
        [string]$LogFilePath,

        [Parameter(Mandatory)]
        [string]$ExecutableName,

        [Parameter()]
        [string]$ExecutableArguments = ""
    )

    function Write-Log {
        param (
            [string]$Message,
            [string]$Level = "INFO"
        )
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $entry = "$timestamp [$Level] $Message"
        # Write to console
        switch ($Level) {
            "INFO" { Write-Host $entry -ForegroundColor White }
            "WARN" { Write-Warning $Message }
            "ERROR" { Write-Error $Message }
        }
        # Append to log file
        Add-Content -Path $LogFilePath -Value $entry
    }

    # Start logging
    Write-Log "=== Install-ZipPackages started ==="

    # Validate 7-Zip presence
    if (-Not (Test-Path -Path $SevenZipPath)) {
        Write-Log "7-Zip executable not found at '$SevenZipPath'. Exiting." "ERROR"
        return
    }

    # Create extraction directory if needed
    if (-Not (Test-Path -Path $ExtractDirectory)) {
        New-Item -ItemType Directory -Path $ExtractDirectory -Force | Out-Null
        Write-Log "Created extraction directory '$ExtractDirectory'."
    }

    # Get all ZIP files
    $archiveFiles = Get-ChildItem -Path $ArchiveDirectory -Filter *.zip

    if ($archiveFiles.Count -eq 0) {
        Write-Log "No archives found in '$ArchiveDirectory'. Nothing to do."
        return
    }

    foreach ($archive in $archiveFiles) {
        Write-Log "Processing archive: $($archive.Name)"

        # Clean up previous extraction
        Get-ChildItem -Path $ExtractDirectory -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cleared extraction directory."

        # Extract archive
        $extractCommand = @(
            "x"
            "`"$($archive.FullName)`""
            "-o`"$ExtractDirectory`""
            "*"
            "-y"
        )

        Write-Log "Extracting '$($archive.Name)' to '$ExtractDirectory'..."
        $process = Start-Process -FilePath $SevenZipPath -ArgumentList $extractCommand -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Log "Extraction failed for '$($archive.Name)' with exit code $($process.ExitCode). Skipping." "WARN"
            continue
        }

        # Find executables
        $executables = Get-ChildItem -Path $ExtractDirectory -Filter $ExecutableName -Recurse

        if ($executables.Count -eq 0) {
            Write-Log "No '$ExecutableName' found in '$($archive.Name)'. Skipping." "WARN"
            continue
        }

        foreach ($exe in $executables) {
            Write-Log "Running installer '$($exe.FullName)' with arguments '$ExecutableArguments'..."
            try {
                $installerProcess = Start-Process -FilePath $exe.FullName -ArgumentList $ExecutableArguments -Wait -PassThru
                if ($installerProcess.ExitCode -ne 0) {
                    Write-Log "Installer '$($exe.Name)' exited with code $($installerProcess.ExitCode)." "WARN"
                } else {
                    Write-Log "Installation completed successfully for '$($exe.Name)'."
                }
            }
            catch {
                Write-Log "Failed to run installer '$($exe.FullName)': $_" "ERROR"
            }
        }

        # Clean up extracted files after install
        Get-ChildItem -Path $ExtractDirectory -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Cleaned up extracted files for '$($archive.Name)'."
    }

    Write-Log "=== Install-ZipPackages completed ==="
}
