# Requires: ActiveDirectory module (RSAT)
Import-Module ActiveDirectory

# Define the groups of interest
$groupsToCheck = @("Administrators", "Domain Admins", "Enterprise Admins")

# Optional: Fully qualified group names, especially if running from a member server
# $domain = (Get-ADDomain).DistinguishedName
# $groupsToCheck = @("Administrators", "Domain Admins", "Enterprise Admins" | ForEach-Object { "CN=$_,CN=Users,$domain" })

# Create a hashtable to store results
$results = @()

# Function to recursively get members
function Get-ADGroupMembersRecursive {
    param (
        [string]$GroupName,
        [string]$DisplayGroupName
    )

    Get-ADGroupMember -Identity $GroupName -Recursive | ForEach-Object {
        if ($_.objectClass -eq 'user') {
            $results += [PSCustomObject]@{
                Name  = $_.Name
                Group = $DisplayGroupName
            }
        }
    }
}

# Process each group
foreach ($group in $groupsToCheck) {
    try {
        Get-ADGroupMembersRecursive -GroupName $group -DisplayGroupName $group
    } catch {
        Write-Warning "Failed to process group '$group': $_"
    }
}

# Output sorted results
$results | Sort-Object Name, Group | Format-Table -AutoSize
