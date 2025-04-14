param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 64)]
    [int]$ProcessorCount
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

# Function to turn off the VM gracefully or forcefully
function Stop-VMIfRunning {
    param (
        [Microsoft.HyperV.PowerShell.VirtualMachine]$VM
    )

    if ($VM.State -eq 'Running') {
        Write-Message "VM '$($VM.Name)' is currently running." "Info"

        $choice = Read-Host "Do you want to shut it down gracefully? (Y/N/F=Force)"

        switch ($choice.ToUpper()) {
            "Y" {
                Write-Message "Attempting graceful shutdown..." "Info"
                Stop-VM -Name $VM.Name -Shutdown -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5
                while ((Get-VM -Name $VM.Name).State -ne 'Off') {
                    Write-Host "." -NoNewline
                    Start-Sleep -Seconds 2
                }
                Write-Host ""
                Write-Message "VM has been shut down." "Success"
            }
            "F" {
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
