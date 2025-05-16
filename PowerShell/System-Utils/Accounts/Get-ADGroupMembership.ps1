Param (
    [Parameter(Mandatory = $true, HelpMessage = "List of Active Directory group names.")]
    [string[]]$adminGroups,

    [Parameter(Mandatory = $true, HelpMessage = "Output file path, e.g. 'C:\\Temp\\AdminUsers.csv'")]
    [string]$OutPutFile
)

# Store results here
$adminUsers = @()

foreach ($group in $adminGroups) {
    try {
        $members = Get-ADGroupMember -Identity $group -ErrorAction Stop | Select-Object Name, SamAccountName
        foreach ($member in $members) {
            $adminUsers += [PSCustomObject]@{
                UserName    = $member.SamAccountName
                DisplayName = $member.Name
                GroupName   = $group
            }
        }
    } catch {
        Write-Warning "Failed to retrieve members of group '$group'. Error: $_"
    }
}

if ($adminUsers.Count -eq 0) {
    Write-Warning "No users found in the provided groups."
} else {
    try {
        $adminUsers | Sort-Object GroupName, DisplayName | Export-Csv -Path $OutPutFile -NoTypeInformation -Encoding UTF8
        Write-Host "Results exported to '$OutPutFile'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to export results to file: $_"
    }
}
