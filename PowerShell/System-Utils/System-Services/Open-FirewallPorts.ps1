# # Allow inbound TCP on port 80
# .\Open-FirewallPort.ps1 -Port 80 -Protocol TCP -RuleName "Allow HTTP"
# # Block outbound UDP on port 53 (DNS)
# .\Open-FirewallPort.ps1 -Port 53 -Protocol UDP -RuleName "Block DNS" -Action Block -Direction Outbound

param (
    [Parameter(Mandatory = $true)]
    [string]$RuleName,             # Name of the firewall rule

    [Parameter()]
    [int]$Port,                    # Port number to open (ignored when removing)

    [Parameter()]
    [ValidateSet("TCP", "UDP")]
    [string]$Protocol,             # Protocol: TCP or UDP (ignored when removing)

    [Parameter()]
    [ValidateSet("Allow", "Block")]
    [string]$Action = "Allow",     # Action to take (default: Allow)

    [Parameter()]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction = "Inbound", # Direction (default: Inbound)

    [switch]$RemoveRule            # Optional: remove the rule instead of creating it
)

# Function to remove the rule
function Remove-FirewallRule {
    $existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
    if ($existingRule) {
        Remove-NetFirewallRule -DisplayName $RuleName
        Write-Host "🗑️ Rule '$RuleName' removed successfully." -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ No rule found with the name '$RuleName'." -ForegroundColor Yellow
    }
}

# If -RemoveRule switch is set
if ($RemoveRule) {
    Remove-FirewallRule
    return
}

# Check required parameters for creating a rule
if (-not $Port -or -not $Protocol) {
    Write-Host "❌ Error: -Port and -Protocol are required when creating a rule!" -ForegroundColor Red
    exit 1
}

# Check if rule already exists
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
