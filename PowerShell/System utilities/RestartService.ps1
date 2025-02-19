Param ( 
    [Parameter(Mandatory=$true)]
        [string]$ServiceName )   # Name of the service that you want to restart
    try {

        Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Host "The service: $ServiceName successfully restarted"
    } catch {
        Write-Host "Failed to restart the service: $ServiceName"
        Write-Host "Error: $_" # Display the error message

        # Optionally you can log the error to the EventLog
        $source = "ServiceRestartScript"
        $logName= "Application"

        if (-not [System.Diagnostics.EventLog]::SourceExists($source)){
            New-EventLog -LogName $logName -Source $source
        }
        Write-EventLog -LogName $logName -Source $source -EntryType Error -EventId 1001 -Message "Error restarting service '$serviceName': $_"
    }