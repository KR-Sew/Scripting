function Restore-WSLImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,  # Name of the WSL distribution to restore

        [Parameter(Mandatory = $true)]
        [string]$BackupFile,   # Path to the .tar file for backup

        [Parameter(Mandatory = $true)]
        [string]$InstallLocation,  # Directory where the distribution will be installed

        [Parameter(Mandatory = $false)]
        [ValidateSet(1, 2)]
        [int]$Version = 2  # WSL version (1 or 2), default is 2
    )

    # Function to check if WSL is installed
    function Test-WSL {
        if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
            Write-Error "WSL is not installed. Please install WSL first."
            return $false
        }
        return $true
    }

    # Function to check if the distribution already exists
    function Test-DistroExists {
        $existingDistros = wsl --list --quiet | ForEach-Object { $_.Trim() }
        if ($existingDistros -contains $Name) {
            Write-Error "The WSL distribution '$Name' already exists. Remove it before restoring."
            return $true
        }
        return $false
    }

    # Function to restore the specified WSL distribution
    function Restore-WSL {
        # Check if the backup file exists
        if (-not (Test-Path -Path $BackupFile)) {
            Write-Error "Backup file '$BackupFile' does not exist."
            return $false
        }

        # Check if the install directory exists, create if needed
        if (-not (Test-Path -Path $InstallLocation)) {
            Write-Host "Creating target folder: $InstallLocation" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $InstallLocation -Force | Out-Null
        }

        # Import the WSL distribution from the backup file
        Write-Host "Restoring WSL distribution '$Name' from '$BackupFile' to '$InstallLocation'..." -ForegroundColor Cyan
        wsl --import $Name $InstallLocation $BackupFile

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Restoration failed."
            return $false
        }

        Write-Host "Restoration completed successfully." -ForegroundColor Green

        # Set WSL version if needed
        if ($Version -eq 2) {
            Write-Host "Setting WSL version to 2 for '$Name'..." -ForegroundColor Yellow
            wsl --set-version $Name 2
            if ($LASTEXITCODE -eq 0) {
                Write-Host "WSL version set to 2." -ForegroundColor Green
            } else {
                Write-Error "Failed to set WSL version to 2."
            }
        }

        return $true
    }

    # Run checks and execute restore
    if (-not (Check-WSL)) { return }
    if (Check-DistroExists) { return }
    Restore-WSL
}

# Example usage:
# Restore-WSLImage -Name "Debian" -BackupFile "D:\tmp\BackupFolder\wsl_backup.tar" -InstallLocation "D:\WSL\Debian" -Version 2
