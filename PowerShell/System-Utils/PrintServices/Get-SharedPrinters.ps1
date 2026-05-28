# Get-RemoteSharedPrinters.ps1
# Query shared printers on a remote Windows Print Server via PowerShell Remoting

param (
    [Parameter(Mandatory = $true)]
    [string]$PrintServer
)

try {
    Write-Host "Connecting to remote server: $PrintServer..." -ForegroundColor Cyan

    $printers = Invoke-Command -ComputerName $PrintServer -ScriptBlock {
        Get-Printer | Where-Object Shared -eq $true |
        Select-Object Name, ShareName, PortName, DriverName, Location, Comment
    }

    if (-not $printers) {
        Write-Host "No shared printers found on $PrintServer." -ForegroundColor Yellow
    } else {
        Write-Host "`nShared Printers on $PrintServer:`n" -ForegroundColor Green
        $printers | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Error connecting to $PrintServer: $_"
}
