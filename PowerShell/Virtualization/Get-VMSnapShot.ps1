<#
.SYNOPSIS
    Retrieves and displays snapshot information for a specified Hyper-V virtual machine with VM name auto-completion.
.DESCRIPTION
    This script retrieves all snapshots (checkpoints) for a given VM and displays detailed information
    including name, creation time, type, and size. Includes improved error handling, output formatting,
    and auto-completion for running VM names.
.PARAMETER VMName
    The name of the virtual machine to query for snapshots. Supports auto-completion of running VMs.
.PARAMETER SortBy
    Optional: Sort snapshots by 'Name', 'CreationTime' (default), or 'Size'.
.EXAMPLE
    .\Get-VMSnapshots.ps1 -VMName "MyVM"
    .\Get-VMSnapshots.ps1 -VMName "MyVM" -SortBy Size
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
    [ValidateSet("Name", "CreationTime", "Size")]
    [string]$SortBy = "CreationTime"
)

# Function to convert bytes to human-readable format
function Get-FriendlySize {
    param ([uint64]$Bytes)
    $sizes = 'B','KB','MB','GB','TB'
    $index = 0
    while ($Bytes -ge 1024 -and $index -lt $sizes.Length) {
        $Bytes /= 1024
        $index++
    }
    return "{0:N2} {1}" -f $Bytes, $sizes[$index]
}

try {
    # Import Hyper-V module
    Import-Module Hyper-V -ErrorAction Stop

    # Get the VM with error handling
    $VM = Get-VM -Name $VMName -ErrorAction Stop
    if (-not $VM) {
        Write-Error "Virtual machine '$VMName' not found."
        exit 1
    }

    # Get snapshots with error handling
    $Snapshots = Get-VMSnapshot -VMName $VMName -ErrorAction Stop
    if (-not $Snapshots) {
        Write-Host "No snapshots found for VM '$VMName'."
        exit 0
    }

    # Calculate snapshot sizes and prepare output
    $SnapshotDetails = $Snapshots | ForEach-Object {
        $size = (Get-VHD -Path $_.HardDrives.Path -ErrorAction SilentlyContinue | Measure-Object -Property Size -Sum).Sum
        [PSCustomObject]@{
            Name = $_.Name
            CreationTime = $_.CreationTime
            SnapshotType = $_.SnapshotType
            Size = $size
            FriendlySize = Get-FriendlySize -Bytes $size
            ParentSnapshot = $_.ParentSnapshotName
        }
    }

    # Sort snapshots based on SortBy parameter
    $SortedSnapshots = switch ($SortBy) {
        "Name" { $SnapshotDetails | Sort-Object Name }
        "CreationTime" { $SnapshotDetails | Sort-Object CreationTime -Descending }
        "Size" { $SnapshotDetails | Sort-Object Size -Descending }
    }

    # Display VM information
    Write-Host "`nVirtual Machine Snapshot Report" -ForegroundColor Cyan
    Write-Host "VM Name: $VMName"
    Write-Host "VM State: $($VM.State)"
    Write-Host "Total Snapshots: $($Snapshots.Count)"
    Write-Host "Sorted By: $SortBy`n"

    # Display snapshot details in a formatted table
    $SortedSnapshots | Format-Table -Property `
        @{Label="Snapshot Name"; Expression={$_.Name}},
        @{Label="Creation Time"; Expression={$_.CreationTime}; FormatString="yyyy-MM-dd HH:mm:ss"},
        @{Label="Type"; Expression={$_.SnapshotType}},
        @{Label="Size"; Expression={$_.FriendlySize}},
        @{Label="Parent Snapshot"; Expression={$_.ParentSnapshotName}} `
        -AutoSize

    # Display total size of all snapshots
    $TotalSize = ($SnapshotDetails | Measure-Object -Property Size -Sum).Sum
    Write-Host "Total Snapshot Size: $(Get-FriendlySize -Bytes $TotalSize)" -ForegroundColor Green

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
} finally {
    # Clean up any resources if needed
}