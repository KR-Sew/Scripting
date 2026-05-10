#requires -version 3.0

<#
.SYNOPSIS
    Enable built-in Administrator account and reset password.

.DESCRIPTION
    Finds the local built-in Administrator account using SID ending with -500,
    enables the account if disabled,
    changes password,
    writes local and optional central logs.

.NOTES
    Recommended deployment:
        Computer Configuration ->
            Policies ->
                Windows Settings ->
                    Scripts (Startup)

    Run as COMPUTER STARTUP script.
#>

#region CONFIG

# !!! CHANGE PASSWORD !!!
$NewPasswordPlain = 'Str0ngP@ssw0rd!2026'

# Optional central log share
# Example:
# \\fileserver\AdminLogs$
$CentralLogShare = '\\v77\Logs$\LocalAdminReset'

# Enable/Disable central logging
$EnableCentralLogging = $true

#endregion

#region LOGGING

$LogDir  = 'C:\ProgramData\LocalAdminReset'
$LogFile = Join-Path $LogDir 'LocalAdminReset.log'

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,

        [ValidateSet('INFO','WARN','ERROR','OK')]
        [string]$Level = 'INFO'
    )

    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $Line = "[${Timestamp}][$Level] $Message"

    Write-Host $Line

    Add-Content -Path $LogFile -Value $Line

    if ($EnableCentralLogging) {
        try {

            if (-not (Test-Path $CentralLogShare)) {
                New-Item -Path $CentralLogShare -ItemType Directory -Force -ErrorAction Stop | Out-Null
            }

            $CentralLogFile = Join-Path $CentralLogShare "$($env:COMPUTERNAME).log"

            Add-Content -Path $CentralLogFile -Value $Line

        }
        catch {
            Write-Host "[WARN] Failed to write central log: $_"
        }
    }
}

#endregion

#region MAIN

try {

    Write-Log "============================================================"
    Write-Log "STARTING LOCAL ADMINISTRATOR PASSWORD RESET"
    Write-Log "============================================================"

    Write-Log "Computer Name : $env:COMPUTERNAME"
    Write-Log "User Context  : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    Write-Log "OS Version    : $((Get-CimInstance Win32_OperatingSystem).Caption)"

    # Find built-in Administrator account by SID ending in -500
    Write-Log "Searching for built-in Administrator account by SID..."

    $AdminAccount = Get-CimInstance Win32_UserAccount `
        -Filter "LocalAccount='True'" |
        Where-Object {
            $_.SID -match '-500$'
        }

    if (-not $AdminAccount) {
        throw "Built-in Administrator account not found."
    }

    Write-Log "Account found:"
    Write-Log "Name : $($AdminAccount.Name)"
    Write-Log "SID  : $($AdminAccount.SID)"

    $ComputerName = $env:COMPUTERNAME
    $AccountName  = $AdminAccount.Name

    # Enable account if disabled
    Write-Log "Checking account state..."

    $ADSPath = "WinNT://$ComputerName/$AccountName,user"

    $User = [ADSI]$ADSPath

    $IsDisabled = ($User.UserFlags.Value -band 0x2)

    if ($IsDisabled) {

        Write-Log "Account is disabled. Enabling..."

        $User.UserFlags = $User.UserFlags.Value -bxor 0x2
        $User.SetInfo()

        Write-Log "Administrator account enabled." -Level OK
    }
    else {
        Write-Log "Administrator account already enabled."
    }

    # Reset password
    Write-Log "Changing password..."

    $User.SetPassword($NewPasswordPlain)
    $User.SetInfo()

    Write-Log "Password changed successfully." -Level OK

    # Verify account status
    $User.RefreshCache()

    Write-Log "Operation completed successfully." -Level OK

    Write-Log "============================================================"

}
catch {

    Write-Log "$($_.Exception.Message)" -Level ERROR

    Write-Log "Operation failed." -Level ERROR

    exit 1
}

#endregion