Param (
    [Parameter(Mandatory=$true)]
        [string[]]$folderNames,   # Define an array of new folder names. Run as .\ProcessValues.ps1 -FolderNames "Dir01", "Dir02", "Dir03"    
        [string]$parentFolder     # Define the path where you want to create the folders  
)


# Define the event log source and log name
$source = "CreateFolderScript" # Name of the source which creates the event
$logName = "Application"       # Log name

# Check if the event source exists, if not, create it
if (-not [System.Diagnostics.EventLog]::SourceExists($source)){
    New-EventLog -LogName $logName -Source $source
}

# Create each folder
foreach ($folderName in $folderNames) {
    try {
         New-Item -Path (Join-Path -Path $parentFolder -ChildPath $folderName) -ItemType Directory -ErrorAction Stop

         $message = "Successfully created folder: $folderNames"
         Write-EventLog -LogName $logname -Source $source -EntryType Error -EventId 1000 -Message $message
        }catch{

            $errorMessage = "Failed to create folder: $folderNames. Error: $_"
            Write-EventLog -LogName $logName -Source $source -EntryType Error -EventId 1001 -Message $errorMessage
        }
    }