# Example usage:
# .\Open-FirewallPort.ps1 -Port 8080 -Protocol TCP -RuleName "My Custom Rule"

param (
    [Parameter(Mandatory = $true)]
    [int]$Port,                     # Port number to open

    [Parameter(Mandatory = $true)]
    [ValidateSet("TCP", "UDP")]
    [string]$Protocol,              # Protocol: TCP or UDP

    [Parameter(Mandatory = $true)]
    [string]$RuleName,             # Name of the firewall rule

    [Parameter()]
    [ValidateSet("Allow", "Block")]
    [string]$Action = "Allow",     # Action to take (default: Allow)

    [Parameter()]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction = "Inbound" # Direction (default: Inbound)
)

# Check if the rule already exists
if (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue) {
    Write-Host "⚠️ Rule '$RuleName' already exists. Aborting." -ForegroundColor Yellow
    exit 1
}

# Create the firewall rule
New-NetFirewallRule -DisplayName $RuleName `
                    -Direction $Direction `
                    -LocalPort $Port `
                    -Protocol $Protocol `
                    -Action $Action `
                    -Enabled True `
                    -Profile Any

Write-Host "✅ Firewall rule '$RuleName' created successfully:"
Write-Host "   → Port: $Port"
Write-Host "   → Protocol: $Protocol"
Write-Host "   → Direction: $Direction"
Write-Host "   → Action: $Action" -ForegroundColor Green
