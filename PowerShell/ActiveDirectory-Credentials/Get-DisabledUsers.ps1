<#
.SYNOPSIS
    Retrieves all disabled Active Directory user accounts with their email addresses.
.DESCRIPTION
    This script queries Active Directory for all disabled user accounts and returns
    their display names, SAM account names, user principal names, and email addresses.
.NOTES
    File Name      : Get-DisabledADAccountsWithEmail.ps1
    Prerequisite   : Active Directory module (RSAT-AD-PowerShell) installed
    Author         : Your Name
#>

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (-not (Get-Module -Name ActiveDirectory)) {
    Write-Error "Active Directory module not found. Please install RSAT-AD-PowerShell."
    exit 1
}

try {
    # Get all disabled user accounts with email addresses
    $disabledAccounts = Get-ADUser -Filter {Enabled -eq $false} -Properties Mail, UserPrincipalName, DisplayName |
                       Where-Object { $_.Mail -ne $null } |
                       Select-Object DisplayName, SamAccountName, UserPrincipalName, Mail, DistinguishedName

    # Check if any disabled accounts were found
    if ($disabledAccounts.Count -eq 0) {
        Write-Host "No disabled user accounts with email addresses found in Active Directory." -ForegroundColor Yellow
        exit 0
    }

    # Display the results
    $disabledAccounts | Format-Table -AutoSize

    # Optionally export to CSV
    $export = Read-Host "Do you want to export the results to CSV? (Y/N)"
    if ($export -eq 'Y' -or $export -eq 'y') {
        $date = Get-Date -Format "yyyyMMdd"
        $csvPath = "C:\Temp\DisabledADAccountsWithEmail_$date.csv"
        $disabledAccounts | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "Results exported to $csvPath" -ForegroundColor Green
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}