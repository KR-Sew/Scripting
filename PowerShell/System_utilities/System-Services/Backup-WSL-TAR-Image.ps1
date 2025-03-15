# Define parameters
param (
    [string]$DistroName = "Ubuntu",  # Change this to your WSL distribution name
    [string]$BackupPath = "C:\path\to\backup\wsl_backup.tar"  # Change this to your desired backup path
)

# Function to check if WSL is installed
function Test-WSL {
    $wslInstalled = wsl --list --verbose 2>$null
    if (-not $wslInstalled) {
        Write-Host "WSL is not installed. Please install WSL first." -ForegroundColor Red
        exit
    }
}

# Function to create a backup of the specified WSL distribution
function Backup-WSL {
    param (
        [string]$DistroName,
        [string]$BackupPath
    )

    # Check if the specified distribution exists
    $distroList = wsl --list --quiet
    if ($distroList -notcontains $DistroName) {
        Write-Host "The specified WSL distribution '$DistroName' does not exist." -ForegroundColor Red
        exit
    }

    # Export the WSL distribution to a .tar file
    Write-Host "Backing up WSL distribution '$DistroName' to '$BackupPath'..."
    wsl --export $DistroName $BackupPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Backup completed successfully." -ForegroundColor Green
    } else {
        Write-Host "Backup failed." -ForegroundColor Red
    }
}

# Check if WSL is installed
Check-WSL

# Create the backup
Backup-WSL -DistroName $DistroName -BackupPath $BackupPath
