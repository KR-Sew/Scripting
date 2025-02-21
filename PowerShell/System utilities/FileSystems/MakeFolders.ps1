# Define the path where you want to create the folders
$parentFolder = ".\SonarQube"

# Define the names of the folders you want to create
$folderNames = @("Backup", "Install", "Manage", "Perf", "UAC")

# Create each folder
foreach ($folderName in $folderNames) {
    New-Item -Path (Join-Path -Path $parentFolder -ChildPath $folderName) -ItemType Directory
}
