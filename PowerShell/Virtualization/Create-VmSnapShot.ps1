<#
.SYNOPSIS
    Creates a new snapshot (checkpoint) for a specified Hyper-V virtual machine with VM name auto-completion.
.DESCRIPTION
    This script creates a new snapshot for a given VM with an optional custom name. Includes error handling,
    auto-completion for running VM names, and confirmation of the snapshot creation.
.PARAMETER VMName
    The name of the virtual machine to create a snapshot for. Supports auto-completion of running VMs.
.PARAMETER SnapshotName
    Optional: The name for the new snapshot. If not provided, a default name with timestamp is used.
.EXAMPLE
    .\New-VMSnapshot.ps1 -VMName "MyVM"
    .\New-VMSnapshot.ps1 -VMName "MyVM" -SnapshotName "Pre-Update-Snapshot"
#>

# Define auto-completion for VMName parameter
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the name of the virtual machine")]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter({
        param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        # Get list of running VMs for auto-completion
        try {
            Import-Module Hyper-V -ErrorAction Stop
            $vms = Get-VM | Where-Object { $_.State -eq 'Running' } | Select-Object -ExpandProperty Name
            return $vms | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
        } catch {
            return @()
        }
    })]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [string]$SnapshotName
)

try {
    # Import Hyper-V module
    Import-Module Hyper-V -ErrorAction Stop

    # Get the VM with error handling
    $VM = Get-VM -Name $VMName -ErrorAction Stop
    if (-not $VM) {
        Write-Error "Virtual machine '$VMName' not found."
        exit 1
    }

    # Generate default snapshot name with timestamp if not provided
    if (-not $SnapshotName) {
        $SnapshotName = "$VMName-Snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }

    # Display VM information before creating snapshot
    Write-Host "`nCreating Snapshot for Virtual Machine" -ForegroundColor Cyan
    Write-Host "VM Name: $VMName"
    Write-Host "VM State: $($VM.State)"
    Write-Host "Snapshot Name: $SnapshotName`n"

    # Create the snapshot
    Checkpoint-VM -Name $VMName -SnapshotName $SnapshotName -ErrorAction Stop

    # Verify snapshot creation
    $CreatedSnapshot = Get-VMSnapshot -VMName $VMName -Name $SnapshotName -ErrorAction Stop
    if ($CreatedSnapshot) {
        Write-Host "Snapshot created successfully!" -ForegroundColor Green
        Write-Host "Snapshot Details:"
        $CreatedSnapshot | Format-Table -Property `
            @{Label="Snapshot Name"; Expression={$_.Name}},
            @{Label="Creation Time"; Expression={$_.CreationTime}; FormatString="yyyy-MM-dd HH:mm:ss"},
            @{Label="Type"; Expression={$_.SnapshotType}} `
            -AutoSize
    } else {
        Write-Error "Failed to verify snapshot creation."
        exit 1
    }

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up any resources if needed
}