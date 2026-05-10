<#
.SYNOPSIS
    Encrypt password using AES key.

.DESCRIPTION
    Reads AES key from file,
    prompts for password securely,
    encrypts password,
    saves encrypted blob to file.

.PARAMETER KeyPath
    Path to AES key file.

.PARAMETER OutputPath
    Path where encrypted password file will be saved.

.EXAMPLE
    .\Protect-Password.ps1 `
        -KeyPath "\\v77\Secure$\aes.key" `
        -OutputPath "\\v77\Secure$\local-admin-password.enc"

.NOTES
    Result file can later be decrypted using:
        ConvertTo-SecureString -Key
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$KeyPath,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

#region FUNCTIONS

function Write-Log {
    param(
        [string]$Message,

        [ValidateSet('INFO','WARN','ERROR','OK')]
        [string]$Level = 'INFO'
    )

    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    Write-Host "[${Timestamp}][$Level] $Message"
}

#endregion

#region MAIN

try {

    Write-Log "============================================================"
    Write-Log "PASSWORD ENCRYPTION STARTED"
    Write-Log "============================================================"

    if (-not (Test-Path $KeyPath)) {
        throw "AES key file not found: $KeyPath"
    }

    Write-Log "Reading AES key..."

    $Base64Key = (Get-Content $KeyPath -ErrorAction Stop).Trim()

    $AesKey = [Convert]::FromBase64String($Base64Key)

    if ($AesKey.Length -ne 32) {
        throw "Invalid AES-256 key length."
    }

    Write-Log "Requesting password input..."

    $SecurePassword = Read-Host "Enter password to encrypt" -AsSecureString

    if (-not $SecurePassword) {
        throw "Password input cancelled."
    }

    Write-Log "Encrypting password..."

    $EncryptedPassword = ConvertFrom-SecureString `
        -SecureString $SecurePassword `
        -Key $AesKey

    $ParentDir = Split-Path $OutputPath -Parent

    if (-not (Test-Path $ParentDir)) {

        Write-Log "Creating directory: $ParentDir"

        New-Item -Path $ParentDir -ItemType Directory -Force | Out-Null
    }

    Write-Log "Saving encrypted password..."

    Set-Content `
        -Path $OutputPath `
        -Value $EncryptedPassword `
        -Encoding ASCII `
        -Force

    Write-Log "Encrypted password file created successfully." -Level OK
    Write-Log "Saved to: $OutputPath"

    Write-Log "============================================================"

}
catch {

    Write-Log "$($_.Exception.Message)" -Level ERROR

    exit 1
}

#endregion