param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$OldNICName,

    [Parameter(Mandatory = $true)]
    [string]$NewNICName
)

# Ensure the VM is running
$vm = Get-VM -Name $VMName -ErrorAction Stop
if ($vm.State -ne 'Running') {
    Write-Error "VM '$VMName' is not running. Please start it before running this script."
    exit 1
}

try {
    Invoke-Command -VMName $VMName -ScriptBlock {
        param($OldNIC, $NewNIC)

        $adapter = Get-NetAdapter -Name $OldNIC -ErrorAction Stop
        Rename-NetAdapter -Name $adapter.Name -NewName $NewNIC -PassThru

    } -ArgumentList $OldNICName, $NewNICName
    Write-Host "NIC renamed successfully inside VM '$VMName'." -ForegroundColor Cyan
} catch {
    Write-Error "Failed to rename NIC inside VM '$VMName': $_"
}
