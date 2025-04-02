# Get the list of all VMs
$vms = Get-VM

# If no VMs are found, exit
if ($vms.Count -eq 0) {
    Write-Host "❌ No virtual machines found!" -ForegroundColor Red
    exit
}

# Display the list of VMs with an index
Write-Host "Available VMs:" -ForegroundColor Cyan
for ($i = 0; $i -lt $vms.Count; $i++) {
    Write-Host "$i. $($vms[$i].Name) - State: $($vms[$i].State)"
}

# Ask the user to select a VM
$selection = Read-Host "Enter the number of the VM you want to manage"

# Validate input
if ($selection -match "^\d+$" -and [int]$selection -ge 0 -and [int]$selection -lt $vms.Count) {
    $selectedVM = $vms[[int]$selection]
    Write-Host "You selected: $($selectedVM.Name) - Current State: $($selectedVM.State)"
    
    # Ask user whether to turn it on or off
    $action = Read-Host "Enter 'on' to start or 'off' to stop the VM"
    
    if ($action -eq "on") {
        Start-VM -Name $selectedVM.Name
        Write-Host "✅ Starting VM: $($selectedVM.Name)" -ForegroundColor Green
    } elseif ($action -eq "off") {
        Stop-VM -Name $selectedVM.Name -Force
        Write-Host "🛑 Stopping VM: $($selectedVM.Name)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Invalid action. Please enter 'on' or 'off'." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Invalid selection. Please enter a valid number." -ForegroundColor Red
}
