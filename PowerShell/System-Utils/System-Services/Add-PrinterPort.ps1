# Add-PrinterPortWithCName.ps1
# Adds a Standard TCP/IP Printer Port using a DNS CNAME as the port name and host address

param (
    [Parameter(Mandatory = $true)]
    [string]$CName,

    [int]$PortNumber = 9100,  # Default for most printers
    [string]$Protocol = "Raw", # Raw (9100) or LPR
    [switch]$Force
)

# Check if the port already exists
if (Get-PrinterPort -Name $CName -ErrorAction SilentlyContinue) {
    if ($Force) {
        Write-Warning "Port '$CName' already exists. Skipping due to -Force."
        return
    } else {
        throw "Printer port '$CName' already exists. Use -Force to suppress this error."
    }
}

# Add the new printer port
try {
    Write-Host "Adding printer port: $CName using $Protocol on port $PortNumber..." -ForegroundColor Cyan

    Add-PrinterPort -Name $CName `
        -PrinterHostAddress $CName `
        -PortNumber $PortNumber `
        -Protocol $Protocol

    Write-Host "Printer port '$CName' added successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to add printer port '$CName': $_"
}
