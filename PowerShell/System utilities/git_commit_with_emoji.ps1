function Select-Files {
    # Get the current directory
    $currentDir = Get-Location

    Write-Host "Interactive Mode: Type 'list' to see files, or 'exit' to quit."
    $selectedFiles = @()

    while ($true) {
        # Read user input
        $inputs = Read-Host "Enter command (or type 'list' to see files)"

        # Exit condition
        if ($inputs -eq 'exit') {
            break
        }

        # List files in the current directory
        if ($inputs -eq 'list') {
            $files = Get-ChildItem -Path $currentDir
            if ($files.Count -eq 0) {
                Write-Host "No files found in the current directory."
            } else {
                Write-Host "Available files:"
                $files | ForEach-Object { Write-Host "$($_.Name) (Index: $($_.PSChildName))" }
            }
            continue
        }

        # Check if the input is a valid file name
        $fullPath = Join-Path -Path $currentDir -ChildPath $input
        if (Test-Path $fullPath) {
            $selectedFiles += $fullPath
            Write-Host "Selected file: $fullPath"
        } else {
            Write-Host "File not found: $fullPath"
        }
    }

    # Output the selected files
    if ($selectedFiles.Count -gt 0) {
        Write-Host "You have selected the following files:"
        $selectedFiles | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "No files selected."
    }
}

# Call the function
Select-Files
