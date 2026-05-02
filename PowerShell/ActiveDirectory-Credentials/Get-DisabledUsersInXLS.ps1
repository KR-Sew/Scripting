<#
.SYNOPSIS
    Exports disabled AD accounts with email and group memberships to Excel (XLSX).
.DESCRIPTION
    This script queries disabled AD users with their email addresses and group memberships,
    then exports the data to an Excel file with formatting.
.NOTES
    Requires:
    - ActiveDirectory module (RSAT-AD-PowerShell)
    - ImportExcel module (install with: Install-Module -Name ImportExcel)
#>

# Check and import required modules
$modules = @('ActiveDirectory', 'ImportExcel')
$missingModules = @()

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        $missingModules += $module
    }
}

if ($missingModules) {
    Write-Host "The following modules are missing: $($missingModules -join ', ')" -ForegroundColor Red
    if ($missingModules -contains 'ImportExcel') {
        Write-Host "Install ImportExcel module with: Install-Module -Name ImportExcel -Force -AllowClobber" -ForegroundColor Yellow
    }
    if ($missingModules -contains 'ActiveDirectory') {
        Write-Host "ActiveDirectory module is part of RSAT tools. Install via Windows Features or PowerShell:"
        Write-Host "Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -ForegroundColor Yellow
    }
    exit 1
}

Import-Module ActiveDirectory
Import-Module ImportExcel

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
    Write-Host "Querying disabled AD accounts..." -ForegroundColor Cyan
    $disabledAccounts = Get-ADUser -Filter {Enabled -eq $false} -Properties Mail, UserPrincipalName, DisplayName, MemberOf, DistinguishedName
    
    if ($disabledAccounts.Count -eq 0) {
        Write-Host "No disabled user accounts found in Active Directory." -ForegroundColor Yellow
        exit 0
    }

    # Process each account to get group memberships
    $results = foreach ($user in $disabledAccounts) {
        Write-Progress -Activity "Processing users" -Status $user.SamAccountName -PercentComplete (($disabledAccounts.IndexOf($user)/$disabledAccounts.Count*100))
        
        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            Username          = $user.SamAccountName
            UPN               = $user.UserPrincipalName
            Email             = $user.Mail
            Groups            = Get-ADUserGroups -DistinguishedName $user.DistinguishedName
            DN                = $user.DistinguishedName
            LastLogonDate     = $user.LastLogonDate
            WhenCreated       = $user.WhenCreated
            WhenChanged       = $user.WhenChanged
        }
    }

    # Create Excel report
    $date = Get-Date -Format "yyyyMMdd"
    $excelPath = Join-Path -Path $env:USERPROFILE -ChildPath "Downloads\Disabled_AD_Accounts_$date.xlsx"
    
    Write-Host "Exporting to Excel file: $excelPath" -ForegroundColor Cyan

    $results | Export-Excel -Path $excelPath -WorksheetName "Disabled Accounts" -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter `
        -TableName "DisabledAccounts" -TableStyle "Medium6" -ConditionalText $(
            New-ConditionalText -Text "Error retrieving groups" -Range "E:E" -ConditionalTextColor DarkRed -BackgroundColor LightYellow
        )

    # Open the Excel file
    $openFile = Read-Host "Do you want to open the Excel file now? (Y/N)"
    if ($openFile -eq 'Y' -or $openFile -eq 'y') {
        Invoke-Item $excelPath
    }

    Write-Host "Export completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}