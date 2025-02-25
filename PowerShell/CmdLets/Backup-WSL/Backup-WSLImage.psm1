function Backup-WSLImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Name")]
        [string]$DistroName,  # Name of the WSL distribution to back up

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$BackupPath   # Directory where the backup file will be saved
    )

    # Function to check if WSL is installed
    function Test-WSL {
        if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
            Write-Error "WSL is not installed. Please install WSL first."
            return $false
        }
        return $true
    }

    # Function to create a backup of the specified WSL distribution
    function Backup-WSL {
        # Get the list of WSL distributions
        $distroList = wsl --list --quiet | ForEach-Object { $_.Trim() }

        # Check if the specified distribution exists
        if ($distroList -notcontains $DistroName) {
            Write-Error "The specified WSL distribution '$DistroName' does not exist."
            return $false
        }

        # Ensure the backup directory exists
        if (-not (Test-Path $BackupPath)) {
            Write-Error "Backup directory '$BackupPath' does not exist."
            return $false
        }

        # Construct the backup file path (d:\temp\Debian_backup.tar)
        $BackupFile = Join-Path -Path $BackupPath -ChildPath "${DistroName}_backup.tar"

        # Export the WSL distribution to the generated file path
        Write-Host "Backing up WSL distribution '$DistroName' to '$BackupFile'..."
        wsl --export $DistroName $BackupFile

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Backup completed successfully: $BackupFile" -ForegroundColor Green
            return $true
        } else {
            Write-Error "Backup failed with error code: $LASTEXITCODE"
            return $false
        }
    }

    # Check if WSL is installed
    if (-not (Test-WSL)) {
        return
    }

    # Create the backup
    Backup-WSL
}

# Example usage
# Backup-WSLImage -Name "Ubuntu" -BackupPath "D:\temp"
# Backup file will be: D:\temp\Ubuntu_backup.tar
