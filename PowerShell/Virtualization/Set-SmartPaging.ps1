param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [string]$DestinationPath
)

# Check if the VM exists
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Error "VM '$VMName' does not exist."
    exit 1
}

# Validate the destination folder
if (-not (Test-Path $DestinationPath)) {
    Write-Host "Destination folder '$DestinationPath' does not exist. Creating it..."
    try {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    } catch {
        Write-Error "Failed to create destination folder. $_"
        exit 1
    }
}

# Set the Smart Paging file location
try {
    Set-VM -Name $VMName -SmartPagingFilePath $DestinationPath
    Write-Host "Smart Paging file path for VM '$VMName' has been successfully set to '$DestinationPath'."
} catch {
    Write-Error "Failed to set Smart Paging file path. $_"
    exit 1
}
