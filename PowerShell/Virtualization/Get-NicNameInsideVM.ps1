param (
    [Parameter(Mandatory=$true)]
    [string]$VMName
)

# Check if VM exists and is running
$vm = Get-VM -Name $VMName -ErrorAction Stop

if ($vm.State -ne 'Running') {
    Write-Error "VM '$VMName' is not running. Start the VM before running this script."
    exit 1
}

try {
    # Use PowerShell Direct to run inside the VM
    Invoke-Command -VMName $VMName -ScriptBlock {
        Get-NetAdapter | Select-Object Name, InterfaceDescription, Status
    }
} catch {
    Write-Error "Failed to connect via PowerShell Direct: $_"
}
