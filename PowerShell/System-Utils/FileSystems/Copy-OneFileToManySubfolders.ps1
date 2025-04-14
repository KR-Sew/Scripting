Param (
    [Parameter(Mandatory=$true)]
    [string]$SourceFile,
    [string]$destinationFolder
)

# Define Event Log Source
$EventSource = "FileCopyScript"
$EventLogName = "Application"

# Ensure Event Log Source Exists
if (-not [System.Diagnostics.EventLog]::SourceExists($EventSource)) {
    New-EventLog -LogName $EventLogName -Source $EventSource
}

# Copy files and log the operation
Get-ChildItem -Path $destinationFolder -Directory | ForEach-Object {
    $DestinationPath = $_.FullName

    # Copy file
    Copy-Item -Path $SourceFile -Destination $DestinationPath -Force

    # Log the copied file
    Write-EventLog -LogName $EventLogName -Source $EventSource -EntryType Information -EventId 1003 -Message "Copied file: $SourceFile to $DestinationPath"
}

# Clear variables
Clear-Variable SourceFile, destinationFolder
