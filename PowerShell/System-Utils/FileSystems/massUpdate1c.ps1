# Set the directory containing the archives
$archiveDir = "D:\tmp\Update"
# Set the directory where you want to extract the files
$extractDir = "D:\tmp\Update\ext"

# Create the extraction directory if it doesn't exist
if (-Not (Test-Path -Path $extractDir)) {
    New-Item -ItemType Directory -Path $extractDir
}

# Get all archive files in the directory
$archiveFiles = Get-ChildItem -Path $archiveDir -Filter *.zip

# Loop through each archive file
foreach ($archive in $archiveFiles) {
    # Extract the archive using 7-Zip
    & "C:\Program Files\7-Zip\7z.exe" x $archive.FullName -o $extractDir * -y

    # Change to the extraction directory
    Set-Location -Path $extractDir

    # Find and execute the setup file with silent key
    $setupFiles = Get-ChildItem -Filter "setup.exe"
    foreach ($setup in $setupFiles) {
        if (Test-Path -Path $setup.FullName) {
            Write-Host "Installing $($setup.Name)..."
            Start-Process -FilePath $setup.FullName -ArgumentList "/s" -Wait
        }
    }

    # Return to the original directory
    Set-Location -Path $archiveDir
}
