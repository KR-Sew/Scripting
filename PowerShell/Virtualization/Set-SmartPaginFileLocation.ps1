param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,  # Name of the VM

    [Parameter(Mandatory = $true)]
    [string]$NewPath  # New Smart Paging file location
)

# Check if VM exists
if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}

# Get VM state
$vm = Get-VM -Name $VMName
$currentSmartPaging = $vm.SmartPagingFilePath
$vmState = $vm.State

Write-Host "Current Smart Paging file location: $currentSmartPaging"
Write-Host "VM State: $vmState"

# Check if the new path exists
if (-not (Test-Path -Path $NewPath)) {
    Write-Host "❌ Error: The specified path '$NewPath' does not exist!" -ForegroundColor Red
    exit 1
}

# Stop the VM if it's running
if ($vmState -eq "Running") {
    Write-Host "⚠ Stopping VM '$VMName' to modify Smart Paging file location..."
    Stop-VM -Name $VMName -Force
    Start-Sleep -Seconds 5  # Wait for the VM to shut down
}

# Change the Smart Paging file location
Write-Host "🔄 Changing Smart Paging file location to '$NewPath'..."
Set-VM -Name $VMName -SmartPagingFilePath $NewPath

# Verify the change
$updatedSmartPaging = (Get-VM -Name $VMName).SmartPagingFilePath
if ($updatedSmartPaging -eq $NewPath) {
    Write-Host "✅ Success: Smart Paging file location updated to '$NewPath'." -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: Failed to update Smart Paging file location!" -ForegroundColor Yellow
}

# Restart the VM if it was running before
if ($vmState -eq "Running") {
    Write-Host "🔄 Restarting VM '$VMName'..."
    Start-VM -Name $VMName
    Write-Host "✅ VM '$VMName' restarted successfully." -ForegroundColor Green
}
