# Define the name of the virtual switch
$virtualSwitchName = "MyVirtualSwitch"

# Define the type of virtual switch (External, Internal, or Private)
$switchType = "External"  # Change to "Internal" or "Private" as needed

# Get all active network adapters
$networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

if ($networkAdapters.Count -eq 0) {
    Write-Host "No active network adapters found. Please ensure you have an active network connection."
    exit
}

# Display the list of active network adapters
Write-Host "Available Network Adapters:"
$networkAdapters | ForEach-Object { Write-Host "$($_.Name) - $($_.InterfaceDescription)" }

# Prompt the user to select a network adapter
$selectedAdapterName = Read-Host "Enter the name of the network adapter you want to use"

# Check if the selected adapter exists
$selectedAdapter = $networkAdapters | Where-Object { $_.Name -eq $selectedAdapterName }

if (-not $selectedAdapter) {
    Write-Host "The specified network adapter '$selectedAdapterName' does not exist. Please check the name and try again."
    exit
}

# Create the virtual switch
try {
    if ($switchType -eq "External") {
        New-VMSwitch -Name $virtualSwitchName -NetAdapterName $selectedAdapter.Name -AllowManagementOS $true
    } elseif ($switchType -eq "Internal") {
        New-VMSwitch -Name $virtualSwitchName -SwitchType Internal
    } elseif ($switchType -eq "Private") {
        New-VMSwitch -Name $virtualSwitchName -SwitchType Private
    } else {
        Write-Host "Invalid switch type specified. Please use 'External', 'Internal', or 'Private'."
        exit
    }
    Write-Host "Virtual switch '$virtualSwitchName' created successfully."
} catch {
    Write-Host "An error occurred: $_"
}
