Param (
    [Parameter(Mandatory = $true, HelpMessage = "Folder path to search.")]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$searchDirectory,

    [Parameter(Mandatory = $true, HelpMessage = "Exact file name to search (e.g. 'report.docx')")]
    [string]$fileName,

    [Parameter(Mandatory = $false, HelpMessage = "File type pattern (e.g. '*.jpg', '*.pdf')")]
    [string]$fileType,

    [string]$OutputCsvPath
)

# Initialize result collection
$allFiles = @()

# Search by file name
if (-not [string]::IsNullOrWhiteSpace($fileName)) {
    try {
        $filesByName = Get-ChildItem -Path $searchDirectory -Recurse -Filter $fileName -ErrorAction Stop
        $allFiles += $filesByName
    } catch {
        Write-Warning "Failed searching for '$fileName': $_"
    }
}

# Search by file type
if (-not [string]::IsNullOrWhiteSpace($fileType)) {
    try {
        $filesByType = Get-ChildItem -Path $searchDirectory -Recurse -Filter $fileType -ErrorAction Stop
        $allFiles += $filesByType
    } catch {
        Write-Warning "Failed searching for '$fileType': $_"
    }
}

# Remove duplicates and output
$allFiles = $allFiles | Select-Object -Unique

if ($allFiles.Count -gt 0) {
    Write-Host "`nFound the following file(s):" -ForegroundColor Cyan
    $allFiles | ForEach-Object { Write-Host $_.FullName }

    if ($OutputCsvPath) {
        try {
            $allFiles | Select-Object FullName, Name, Length, LastWriteTime |
                Export-Csv -Path $OutputCsvPath -NoTypeInformation -Encoding UTF8
            Write-Host "`nResults saved to: $OutputCsvPath" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to export results to CSV: $_"
        }
    }
} else {
    Write-Host "No files found matching the criteria." -ForegroundColor Yellow
}
