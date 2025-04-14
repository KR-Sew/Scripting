param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 64)]
    [int]$ProcessorCount,

    [switch]$StartAfter
)

# Function to display colored messages
function Write-Message {
    param (
        [string]$Message,
        [ValidateSet("Info", "Error", "Success")]
        [string]$MessageType = "Info"
    )

    switch ($MessageType) {
        "Info"    { Write-Host "[INFO]    $Message" -ForegroundColor Cyan }
        "Error"   { Write-Host "[ERROR]   $Message" -ForegroundColor Red }
        "Success" { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
    }
}

# Function to turn off the VM forcefully
function Stop-VMIfRunning {
    param (
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM
    )

    if ($VM.State -eq 'Running') {
        Write-Message "VM '$($VM.Name)' is currently running." "Info"

        $choice = Read-Host "Do you want to turn it off forcefully? (Y/N)"

        switch ($choice.ToUpper()) {
            "Y" {
                Write-Message "Force stopping the VM..." "Info"
                Stop-VM -Name $VM.Name -TurnOff -Force
                Write-Message "VM has been forcefully turned off." "Success"
            }
            default {
                Write-Message "Aborted by user." "Error"
                exit 1
            }
        }
    }
}

# Check if VM exists
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Message "VM '$VMName' not found." "Error"
    exit 1
}

# Turn off VM if needed
Stop-VMIfRunning -VM $vm

# Set the number of virtual processors
Set-VMProcessor -VMName $VMName -Count $ProcessorCount
Write-Message "Processor count for '$VMName' set to $ProcessorCount." "Success"

# Optionally start the VM again
if ($StartAfter) {
    Start-VM -Name $VMName | Out-Null
    Write-Message "VM '$VMName' has been started." "Success"
}
