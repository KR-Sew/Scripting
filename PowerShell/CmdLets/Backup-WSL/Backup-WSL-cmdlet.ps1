function Backup-WSLImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DistroName,  # Name of the WSL distribution to back up

        [Parameter(Mandatory = $true)]
        [string]$BackupPath   # Path where the backup .tar file will be saved
    )

    # Function to check if WSL is installed
    function Test-WSL {
        $wslInstalled = wsl --list --verbose 2>$null
        if (-not $wslInstalled) {
            Write-Error "WSL is not installed. Please install WSL first."
            return $false
        }
        return $true
    }

    # Function to create a backup of the specified WSL distribution
    function Backup-WSL {
        # Check if the specified distribution exists
        $distroList = wsl --list --quiet
        if ($distroList -notcontains $DistroName) {
            Write-Error "The specified WSL distribution '$DistroName' does not exist."
            return $false
        }

        # Export the WSL distribution to a .tar file
        Write-Host "Backing up WSL distribution '$DistroName' to '$BackupPath'..."
        wsl --export $DistroName $BackupPath

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Backup completed successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Error "Backup failed."
            return $false
        }
    }

    # Check if WSL is installed
    if (-not (Check-WSL)) {
        return
    }

    # Create the backup
    Backup-WSL
}

# Example usage
# Backup-WSLImage -DistroName "Ubuntu" -BackupPath "C:\path\to\backup\wsl_backup.tar"
