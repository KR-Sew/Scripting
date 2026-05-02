# Define the path to the file containing the usernames
$userListFile = "C:\Temp\usernames.txt"

# Define the groups from which users will be removed
$srcGroups = @("Администраторы домена", "Администраторы предприятия", "Администраторы", "Администраторы 1С")  

# Import the Active Directory module
Import-Module ActiveDirectory

# Read the usernames from the file
if (Test-Path $userListFile) {
    $usernames = Get-Content -Path $userListFile
} else {
    Write-Host "User list file not found: $userListFile"
    exit
}

# Loop through each username and remove from specified groups
foreach ($username in $usernames) {
    foreach ($srcGroup in $srcGroups) {
        try {
            # Remove user from the group
            Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false
            Write-Host "Removed $username from $srcGroup" >> "C:\Temp\DeletedAdminUsers.txt"
        } catch {
            Write-Host "Failed to remove $username from $srcGroup : $_"
        }
    }
}
