<#
.SYNOPSIS
    Retrieves all disabled Active Directory user accounts with their email addresses and group memberships.
.DESCRIPTION
    This script queries Active Directory for all disabled user accounts and returns
    their display names, SAM account names, user principal names, email addresses,
    and all security groups they belong to.
.NOTES
    File Name      : Get-DisabledADAccountsWithGroups.ps1
    Prerequisite   : Active Directory module (RSAT-AD-PowerShell) installed
    Author         : Your Name
#>

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (-not (Get-Module -Name ActiveDirectory)) {
    Write-Error "Active Directory module not found. Please install RSAT-AD-PowerShell."
    exit 1
}

function Get-ADUserGroups {
    param (
        [string]$DistinguishedName
    )
    
    try {
        $groups = Get-ADUser -Identity $DistinguishedName -Properties MemberOf | 
                  Select-Object -ExpandProperty MemberOf |
                  ForEach-Object {
                      (Get-ADGroup $_).Name
                  }
        return ($groups -join ", ")
    }
    catch {
        return "Error retrieving groups"
    }
}

try {
    # Get all disabled user accounts
    $disabledAccounts = Get-ADUser -Filter {Enabled -eq $false} -Properties Mail, UserPrincipalName, DisplayName, MemberOf, DistinguishedName
    
    # Check if any disabled accounts were found
    if ($disabledAccounts.Count -eq 0) {
        Write-Host "No disabled user accounts found in Active Directory." -ForegroundColor Yellow
        exit 0
    }

    # Process each account to get group memberships
    $results = foreach ($user in $disabledAccounts) {
        $groups = Get-ADUserGroups -DistinguishedName $user.DistinguishedName
        
        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            SamAccountName   = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            Email            = $user.Mail
            Groups           = $groups
            DistinguishedName = $user.DistinguishedName
        }
    }

    # Display the results
    $results | Format-Table -AutoSize -Wrap

    # Optionally export to CSV
    $export = Read-Host "Do you want to export the results to CSV? (Y/N)"
    if ($export -eq 'Y' -or $export -eq 'y') {
        $date = Get-Date -Format "yyyyMMdd"
        $csvPath = "DisabledADAccountsWithGroups_$date.csv"
        $results | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "Results exported to $csvPath" -ForegroundColor Green
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}