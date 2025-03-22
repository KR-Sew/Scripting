param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$VMSwitch
)

# Check if the VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "VM '$VMName' not found." -ForegroundColor Red
    exit 1
}

# Check if the switch exists
if (-not (Get-VMSwitch -Name $VMSwitch -ErrorAction SilentlyContinue)) {
    Write-Host "Virtual Switch '$VMSwitch' not found." -ForegroundColor Red
    exit 1
}

# Add the network adapter
try {
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $VMSwitch -Name "Network Adapter"
    Write-Host "Network adapter added to VM '$VMName' using switch '$VMSwitch'." -ForegroundColor Green
} catch {
    Write-Host "Failed to add network adapter: $_" -ForegroundColor Red
}
