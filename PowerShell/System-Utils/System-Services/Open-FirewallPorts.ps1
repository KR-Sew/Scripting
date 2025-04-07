param (
    [Parameter(Mandatory = $true)]
    [int]$Port,                     # Port number to open

    [Parameter(Mandatory = $true)]
    [ValidateSet("TCP", "UDP")]
    [string]$Protocol,              # Protocol: TCP or UDP

    [Parameter(Mandatory = $true)]
    [string]$RuleName               # Name of the firewall rule
)

# Check if the rule already exists
if (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue) {
    Write-Host "⚠️ Rule '$RuleName' already exists. Aborting." -ForegroundColor Yellow
    exit 1
}

# Create the firewall rule
New-NetFirewallRule -DisplayName $RuleName `
                    -Direction Inbound `
                    -LocalPort $Port `
                    -Protocol $Protocol `
                    -Action Allow `
                    -Enabled True `
                    -Profile Any

Write-Host "✅ Firewall rule '$RuleName' created successfully to allow $Protocol on port $Port." -ForegroundColor Green
