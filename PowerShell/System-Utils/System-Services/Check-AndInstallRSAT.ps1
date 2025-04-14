# Check for RSAT capabilities
$rsatFeatures = Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State

# Check if any RSAT features are available
if ($rsatFeatures) {
    Write-Host "Available RSAT Features:"
    $rsatFeatures | ForEach-Object {
        Write-Host "$($_.DisplayName) - $($_.State)"
    }

    # Prompt user for installation
    $featuresToInstall = @()
    foreach ($feature in $rsatFeatures) {
        if ($feature.State -eq 'NotPresent') {
            $install = Read-Host "Do you want to install the feature '$($feature.DisplayName)'? (Y/N)"
            if ($install -eq 'Y') {
                $featuresToInstall += $feature.DisplayName
            }
        }
    }

    # Install selected features
    if ($featuresToInstall.Count -gt 0) {
        foreach ($feature in $featuresToInstall) {
            Add-WindowsCapability -Online -Name $feature
            Write-Host "Installing $feature..."
        }
        Write-Host "Installation complete."
    } else {
        Write-Host "No features selected for installation."
    }
} else {
    Write-Host "Unfortunately, that compatibility test has not passed. No RSAT features are available for this system."
}
