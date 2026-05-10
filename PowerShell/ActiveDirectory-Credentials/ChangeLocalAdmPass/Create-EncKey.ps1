<#
.SYNOPSIS
    Generate AES-256 key file.

.DESCRIPTION
    Creates a cryptographically secure AES key
    and saves it as Base64 text.

.PARAMETER OutputPath
    Path where AES key file will be saved.

.EXAMPLE
    .\New-AesKey.ps1 -OutputPath "\\v77\Secure$\aes.key"

.NOTES
    Recommended permissions:
        - Administrators : Full
        - SYSTEM         : Full
        - Domain Computers : Read (if needed)
#>

[CmdletBinding()]
param(
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
    Write-Log "AES KEY GENERATION STARTED"
    Write-Log "============================================================"

    $ParentDir = Split-Path $OutputPath -Parent

    if (-not (Test-Path $ParentDir)) {

        Write-Log "Creating directory: $ParentDir"

        New-Item -Path $ParentDir -ItemType Directory -Force | Out-Null
    }

    Write-Log "Generating AES-256 key..."

    $AesKey = New-Object byte[] 32

    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AesKey)

    $Base64Key = [Convert]::ToBase64String($AesKey)

    Write-Log "Saving key file..."

    Set-Content `
        -Path $OutputPath `
        -Value $Base64Key `
        -Encoding ASCII `
        -Force

    Write-Log "AES key successfully created." -Level OK
    Write-Log "Saved to: $OutputPath"

    Write-Log "============================================================"

}
catch {

    Write-Log "$($_.Exception.Message)" -Level ERROR

    exit 1
}

#endregion