<#
.SYNOPSIS
    Exports disabled AD accounts with email, groups, phone numbers to Excel with unique filename.
.DESCRIPTION
    This script queries disabled AD users with their contact info and group memberships,
    then exports to Excel with automatic unique filename generation if file exists.
.NOTES
    Requires:
    - ActiveDirectory module (RSAT-AD-PowerShell)
    - ImportExcel module (install with: Install-Module -Name ImportExcel)
#>

# Check and import required modules
$requiredModules = @('ActiveDirectory', 'ImportExcel')
$missingModules = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }

if ($missingModules) {
    Write-Host "Missing modules: $($missingModules -join ', ')" -ForegroundColor Red
    if ($missingModules -contains 'ImportExcel') {
        Write-Host "Install with: Install-Module -Name ImportExcel -Force -AllowClobber" -ForegroundColor Yellow
    }
    if ($missingModules -contains 'ActiveDirectory') {
        Write-Host "Install RSAT AD tools with:" -ForegroundColor Yellow
        Write-Host "Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -ForegroundColor Yellow
    }
    exit 1
}

Import-Module ActiveDirectory
Import-Module ImportExcel

function Get-ADUserGroups {
    param ([string]$DistinguishedName)
    
    try {
        $groups = Get-ADUser -Identity $DistinguishedName -Properties MemberOf | 
                  Select-Object -ExpandProperty MemberOf |
                  ForEach-Object { (Get-ADGroup $_).Name }
        return ($groups -join ", ")
    }
    catch {
        return "Error retrieving groups"
    }
}

function Get-UniqueFilename {
    param (
        [string]$basePath,
        [string]$baseName,
        [string]$extension
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $attempt = 1
    $fullPath = "$basePath\$baseName`_$timestamp$extension"
    
    while (Test-Path $fullPath) {
        $fullPath = "$basePath\$baseName`_$timestamp`_$attempt$extension"
        $attempt++
    }
    
    return $fullPath
}

try {
    # Define properties to retrieve
    $properties = @(
        'DisplayName',
        'SamAccountName',
        'UserPrincipalName',
        'Mail',
        'MemberOf',
        'DistinguishedName',
        'LastLogonDate',
        'WhenCreated',
        'WhenChanged',
        'TelephoneNumber',
        'MobilePhone',
        'OfficePhone'
    )

    # Get all disabled user accounts
    Write-Host "Querying disabled AD accounts..." -ForegroundColor Cyan
    $disabledAccounts = Get-ADUser -Filter {Enabled -eq $false} -Properties $properties
    
    if (-not $disabledAccounts) {
        Write-Host "No disabled user accounts found." -ForegroundColor Yellow
        exit 0
    }

    # Process accounts with progress indicator
    $results = foreach ($user in $disabledAccounts) {
        Write-Progress -Activity "Processing users" -Status $user.SamAccountName -PercentComplete ($disabledAccounts.IndexOf($user)/$disabledAccounts.Count*100)
        
        [PSCustomObject]@{
            DisplayName    = $user.DisplayName
            Username       = $user.SamAccountName
            UPN            = $user.UserPrincipalName
            Email          = $user.Mail
            Telephone      = $user.TelephoneNumber
            Mobile         = $user.MobilePhone
            OfficePhone    = $user.OfficePhone
            Groups         = Get-ADUserGroups -DistinguishedName $user.DistinguishedName
            LastLogonDate  = $user.LastLogonDate
            AccountCreated = $user.WhenCreated
            LastModified   = $user.WhenChanged
            DN             = $user.DistinguishedName
        }
    }

    # Create unique filename
    $baseName = "Disabled_AD_Accounts"
    $downloadsPath = [Environment]::GetFolderPath("MyDocuments")
    $excelPath = Get-UniqueFilename -basePath $downloadsPath -baseName $baseName -extension ".xlsx"
    
    Write-Host "Exporting to Excel file: $excelPath" -ForegroundColor Cyan

    $excelParams = @{
        Path          = $excelPath
        WorksheetName = "Disabled Accounts"
        AutoSize      = $true
        FreezeTopRow  = $true
        BoldTopRow    = $true
        AutoFilter    = $true
        TableName     = "DisabledAccounts"
        TableStyle    = "Medium6"
    }

    $results | Export-Excel @excelParams -ConditionalText @(
        New-ConditionalText -Text "Error retrieving groups" -Range "H:H" -ConditionalTextColor DarkRed -BackgroundColor LightYellow
        New-ConditionalText -Text "" -Range "D:D" -ConditionalTextColor White -BackgroundColor Red -ConditionalType ContainsBlanks
    )

    # Open the Excel file
    $openFile = Read-Host "Do you want to open the Excel file now? (Y/N)"
    if ($openFile -in 'Y','y') {
        Invoke-Item $excelPath
    }

    Write-Host "Export completed successfully!" -ForegroundColor Green
    Write-Host "File saved to: $excelPath" -ForegroundColor Cyan
}
catch {
    Write-Error "Script failed: $_"
    exit 1
}