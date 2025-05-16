Param (
    [Parameter(Mandatory=$True)]
    [string]$searchDirectory, # Set a path of a folder
    
    [Parameter(Mandatory=$True)]
    [string]$fileName,   # Set the name of the file you're looking for
    
    [string]$filesByType # Set the file type you're looking for (e.g., *.jpg, *.pdf)
)

# Initialize an array to hold results
$allFiles = @()

# Search for files by name if $fileName is not empty
if (-not [string]::IsNullOrEmpty($fileName)) {
    $filesByName = Get-ChildItem -Path $searchDirectory -Recurse -Filter $fileName -ErrorAction SilentlyContinue
    $allFiles += $filesByName
}

# Search for files by type if $fileType is not empty
if (-not [string]::IsNullOrEmpty($fileType)) {
    $filesByType = Get-ChildItem -Path $searchDirectory -Recurse -Filter $fileType -ErrorAction SilentlyContinue
    $allFiles += $filesByType
}

# Output results
if ($allFiles) {
    Write-Host "Found the following files:"
    $allFiles | ForEach-Object { Write-Host $_.FullName }
} else {
    Write-Host "No files found matching the criteria."
}
