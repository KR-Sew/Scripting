# Add-MDaemonLDAPAddressBook.ps1
<#
.SYNOPSIS
    Adds MDaemon LDAP address book with optional authentication to Outlook 2021.
.DESCRIPTION
    Adds registry entries to configure Outlook LDAP address book settings.
#>

# Configuration – customize below
$ldapServer     = "mdaemon.domain.local"
$ldapPort       = 389
$ldapDisplayName = "MDaemon Address Book"
$baseDN         = "dc=domain,dc=local"
$ldapTimeout    = 60
$maxEntries     = 100
$useSSL         = 0        # Set to 1 if using LDAPS (port 636)
$requireAuth    = 1        # Set to 1 to enable authentication
$ldapUsername   = "cn=ldapuser,ou=users,dc=domain,dc=local"  # Your LDAP DN
$ldapPassword   = "YourStrongPassword"                      # WARNING: plaintext

# Registry path (Outlook 2021)
$regPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\LDAP\"
$guid = [guid]::NewGuid().ToString()
$key = "$regPath$guid"

# Create LDAP address book key
New-Item -Path $key -Force | Out-Null

Set-ItemProperty -Path $key -Name "DisplayName" -Value $ldapDisplayName
Set-ItemProperty -Path $key -Name "ServerName" -Value $ldapServer
Set-ItemProperty -Path $key -Name "PortNumber" -Value $ldapPort
Set-ItemProperty -Path $key -Name "SearchBase" -Value $baseDN
Set-ItemProperty -Path $key -Name "SearchTimeout" -Value $ldapTimeout
Set-ItemProperty -Path $key -Name "MaxEntriesReturned" -Value $maxEntries
Set-ItemProperty -Path $key -Name "UseSSL" -Value $useSSL
Set-ItemProperty -Path $key -Name "RequireAuth" -Value $requireAuth

# Set credentials only if auth is required
if ($requireAuth -eq 1) {
    Set-ItemProperty -Path $key -Name "AuthUserName" -Value $ldapUsername
    Set-ItemProperty -Path $key -Name "AuthPassword" -Value $ldapPassword
}

Write-Host "LDAP address book '$ldapDisplayName' added to Outlook."

