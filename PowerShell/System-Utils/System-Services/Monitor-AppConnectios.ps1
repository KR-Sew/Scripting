# Monitor-AppConnections.ps1
# Monitors TCP/UDP connections for a specified application or service

param (
    [Parameter(Mandatory=$true)]
    [string]$ProcessName,
    [int]$Interval = 5,  # Time between checks in seconds
    [switch]$IncludeUDP
)

# Function to get process ID from process name
function Get-ProcessId {
    param ([string]$Name)
    $process = Get-Process -Name $Name -ErrorAction SilentlyContinue
    if ($process) {
        return $process.Id
    }
    Write-Host "Process $Name not found." -ForegroundColor Red
    exit
}

# Get initial process ID
$pid = Get-ProcessId -Name $ProcessName

Write-Host "Monitoring connections for $ProcessName (PID: $pid)..."
Write-Host "Press Ctrl+C to stop monitoring."

# Main monitoring loop
try {
    while ($true) {
        # Clear screen for better readability
        Clear-Host
        Write-Host "Monitoring $ProcessName (PID: $pid) - $(Get-Date)"
        Write-Host "----------------------------------------"

        # Get TCP connections
        Write-Host "TCP Connections:" -ForegroundColor Cyan
        $tcpConnections = Get-NetTCPConnection -OwningProcess $pid -ErrorAction SilentlyContinue
        if ($tcpConnections) {
            $tcpConnections | Format-Table -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State, CreationTime -AutoSize
        } else {
            Write-Host "No TCP connections found."
        }

        # Get UDP endpoints if requested
        if ($IncludeUDP) {
            Write-Host "UDP Endpoints:" -ForegroundColor Cyan
            $udpEndpoints = Get-NetUDPEndpoint -OwningProcess $pid -ErrorAction SilentlyContinue
            if ($udpEndpoints) {
                $udpEndpoints | Format-Table -Property LocalAddress, LocalPort, CreationTime -AutoSize
            } else {
                Write-Host "No UDP endpoints found."
            }
        }

        # Wait for the specified interval
        Start-Sleep -Seconds $Interval
    }
}
catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    Write-Host "Monitoring stopped."
}