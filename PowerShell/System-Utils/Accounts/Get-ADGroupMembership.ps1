Param (
    [Parameter(Mandatory=$True)]
    [string[]]$adminGroups,
    [Parameter(Mandatory=$True)]
    [string]$ReportPath
)
$adminGroups = @("Администраторы домена", "Администраторы предприятия", "Администраторы", "Администраторы 1С")
$adminUsers = @()

foreach ($group in $adminGroups) {
    $members = Get-ADGroupMember -Identity $group | Select-Object Name, SamAccountName
    foreach ($member in $members) {
        
        $adminUsers += [PSCustomObject]@{
            UserName = $member.SamAccountName
            DisplayName = $member.Name
            GroupName = $group
        }
    }
}


$adminUsers | Sort-Object GroupName,DisplayName | Format-Table -AutoSize > "C:\Temp\ArrangedAdminsOnGroupWith_1C.txt"
