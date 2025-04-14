param (
    [string]$HostToPing = "google.com",
    [int]$DelaySeconds = 5,
    [switch]$PlaySound
)

# Ensure required assemblies are loaded if BurntToast is not available
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Add-Type -AssemblyName System.Windows.Forms
    if ($PlaySound) {
        Add-Type -AssemblyName PresentationCore
    }
}

function Show-Notification {
    param ([string]$Message)

    if (Get-Module -ListAvailable -Name BurntToast) {
        Import-Module BurntToast -ErrorAction SilentlyContinue
        New-BurntToastNotification -Text "Host Available!", $Message
    } else {
        [System.Windows.Forms.MessageBox]::Show($Message, "Notification", 0, [System.Windows.Forms.MessageBoxIcon]::Information)
        if ($PlaySound) {
            [System.Media.SystemSounds]::Beep.Play()
        }
    }
}

Write-Host "Pinging $HostToPing every $DelaySeconds seconds... (press Ctrl+C to cancel)"
try {
    while ($true) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        if (Test-Connection -ComputerName $HostToPing -Count 1 -Quiet) {
            Write-Host "[$timestamp] $HostToPing is reachable!"
            Show-Notification -Message "$HostToPing is now online!"
            break
        } else {
            Write-Host "[$timestamp] $HostToPing not reachable. Retrying in $DelaySeconds seconds..."
        }
        Start-Sleep -Seconds $DelaySeconds
    }
} finally {
    Write-Host "`nMonitoring stopped."
}
