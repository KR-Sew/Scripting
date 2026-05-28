# Get-SharedPrinters.ps1
# Lists shared printers from a remote or local Print Server

param (
    [string]$PrintServer = $env:COMPUTERNAME  # Default to local server
)

try {
    Write-Host "Getting list of shared printers from: $PrintServer`n" -ForegroundColor Cyan

    $printers = Get-WmiObject -Class Win32_Printer -ComputerName $PrintServer | Where-Object {
        $_.Shared -eq $true
    }

    if ($printers.Count -eq 0) {
        Write-Host "No shared printers found on $PrintServer." -ForegroundColor Yellow
    } else {
        $printers | Select-Object Name, ShareName, PortName, DriverName, Location, Comment | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Failed to connect to Print Server '$PrintServer': $_"
}
