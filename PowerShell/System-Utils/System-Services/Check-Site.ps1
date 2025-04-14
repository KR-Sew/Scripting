
# Define the host to ping
Param (
     [string]$HostToPing = "google.com",
     [int]$DelaySeconds = 5  # Time interval between pings
)
# Function to show notification
function Show-Notification {
    param ([string]$Message)

    # Try BurntToast notification if available
    if (Get-Module -ListAvailable -Name BurntToast) {
        New-BurntToastNotification -Text "Host Available!", $Message
    }
    else {
        # Fallback to Windows pop-up message
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($Message, "Notification", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

# Loop until the host is reachable
Write-Host "Pinging $HostToPing every $DelaySeconds seconds..."
while ($true) {
    if (Test-Connection -ComputerName $HostToPing -Count 1 -Quiet) {
        Write-Host "$HostToPing is reachable!"
        Show-Notification -Message "$HostToPing is now online!"
        break
    }
    Start-Sleep -Seconds $DelaySeconds
}
