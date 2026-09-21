#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [switch]$StopBrowsers
)

$ErrorActionPreference = 'Stop'

Write-Host
Write-Host 'Java cache cleanup' -ForegroundColor Cyan
Write-Host '==================' -ForegroundColor Cyan

function Write-Status {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('OK', 'INFO', 'WARN', 'FAIL', 'SKIP')]
        [string]$Type,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = switch ($Type) {
        'OK'   { 'Green' }
        'INFO' { 'Cyan' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
        'SKIP' { 'DarkGray' }
    }

    Write-Host "[$Type] $Message" -ForegroundColor $Color
}

# Resolve the user account and its profile.
try {
    $Account = New-Object System.Security.Principal.NTAccount($UserName)

    $SID = $Account.Translate(
        [System.Security.Principal.SecurityIdentifier]
    ).Value

    $accProfile = Get-CimInstance -ClassName Win32_UserProfile |
        Where-Object { $_.SID -eq $SID } |
        Select-Object -First 1

    if (-not $accProfile) {
        throw "Windows profile for '$UserName' was not found."
    }

    $accProfilePath = $accProfile.LocalPath

    if (-not (Test-Path -LiteralPath $accProfilePath)) {
        throw "Profile directory does not exist: $accProfilePath"
    }

    Write-Status -Type OK -Message "Account SID: $SID"
    Write-Status -Type OK -Message "Profile path: $accProfilePath"
}
catch {
    Write-Status -Type FAIL -Message $_.Exception.Message
    exit 1
}

$RequestedShortName = $UserName -replace '^.*\\', ''

$ProcessNames = @(
    'java.exe'
    'javaw.exe'
    'javaws.exe'
    'jp2launcher.exe'
    'javacpl.exe'
    'jusched.exe'
)

if ($StopBrowsers) {
    $ProcessNames += @(
        'msedge.exe'
        'chrome.exe'
        'firefox.exe'
        'iexplore.exe'
    )
}

Write-Status -Type INFO `
    -Message "Looking for related processes owned by $UserName..."

$ProcessesStopped = 0

$Processes = Get-CimInstance -ClassName Win32_Process |
    Where-Object { $ProcessNames -contains $_.Name }

foreach ($Process in $Processes) {
    try {
        $Owner = Invoke-CimMethod `
            -InputObject $Process `
            -MethodName GetOwner `
            -ErrorAction Stop

        if ($Owner.ReturnValue -ne 0 -or -not $Owner.User) {
            continue
        }

        if ($Owner.Domain) {
            $FullOwner = "$($Owner.Domain)\$($Owner.User)"
        }
        else {
            $FullOwner = $Owner.User
        }

        $OwnedByRequestedUser =
            $Owner.User -ieq $RequestedShortName -or
            $FullOwner -ieq $UserName

        if (-not $OwnedByRequestedUser) {
            continue
        }

        $ProcessDescription = (
            '{0}, PID {1}, owner {2}' -f
            $Process.Name,
            $Process.ProcessId,
            $FullOwner
        )

        Write-Status -Type INFO `
            -Message "Stopping $ProcessDescription..."

        if ($PSCmdlet.ShouldProcess(
            $ProcessDescription,
            'Stop process'
        )) {
            Stop-Process `
                -Id $Process.ProcessId `
                -Force `
                -ErrorAction Stop

            $ProcessesStopped++
        }
    }
    catch {
        $WarningMessage = (
            'Could not stop {0}, PID {1}: {2}' -f
            $Process.Name,
            $Process.ProcessId,
            $_.Exception.Message
        )

        Write-Status -Type WARN -Message $WarningMessage
    }
}

if ($ProcessesStopped -gt 0) {
    Write-Status -Type OK `
        -Message "Stopped processes: $ProcessesStopped"

    Start-Sleep -Seconds 2
}
else {
    Write-Status -Type INFO `
        -Message 'No related processes needed to be stopped.'
}

$CachePaths = @(
    "$accProfilePath\AppData\LocalLow\Sun\Java\Deployment\cache"
    "$accProfilePath\AppData\LocalLow\Sun\Java\Deployment\tmp"
    "$accProfilePath\AppData\Local\Sun\Java\Deployment\cache"
    "$accProfilePath\AppData\Local\Sun\Java\Deployment\tmp"
    "$accProfilePath\.cache\icedtea-web\cache"
)

$CleanedPaths = 0
$FailedPaths = 0

foreach ($CachePath in $CachePaths) {
    if (-not (Test-Path -LiteralPath $CachePath)) {
        Write-Status -Type SKIP -Message "Not found: $CachePath"
        continue
    }

    Write-Status -Type INFO -Message "Cleaning: $CachePath"

    if (-not $PSCmdlet.ShouldProcess(
        $CachePath,
        'Delete Java cache contents'
    )) {
        continue
    }

    $CleanupSucceeded = $false

    # Retry in case a terminated process has not released its handles yet.
    foreach ($Attempt in 1..3) {
        try {
            Get-ChildItem `
                -LiteralPath $CachePath `
                -Force `
                -ErrorAction Stop |
                Remove-Item `
                    -Recurse `
                    -Force `
                    -ErrorAction Stop

            $CleanupSucceeded = $true
            break
        }
        catch {
            if ($Attempt -lt 3) {
                Write-Status -Type WARN -Message (
                    "Cleanup attempt $Attempt failed; retrying..."
                )

                Start-Sleep -Seconds 2
            }
            else {
                $FailureMessage = (
                    'Could not clean {0}: {1}' -f
                    $CachePath,
                    $_.Exception.Message
                )

                Write-Status -Type FAIL -Message $FailureMessage
            }
        }
    }

    if ($CleanupSucceeded) {
        $CleanedPaths++
        Write-Status -Type OK -Message "Cleaned: $CachePath"
    }
    else {
        $FailedPaths++
    }
}

Write-Host
Write-Host 'Cleanup summary' -ForegroundColor Cyan
Write-Host '===============' -ForegroundColor Cyan
Write-Status -Type INFO -Message "Processes stopped: $ProcessesStopped"
Write-Status -Type INFO -Message "Cache locations cleaned: $CleanedPaths"
Write-Status -Type INFO -Message "Cache locations failed: $FailedPaths"

if ($FailedPaths -gt 0) {
    Write-Status -Type WARN -Message (
        'Some files may still be locked by another process or service.'
    )

    exit 2
}

Write-Status -Type OK -Message 'Java cache cleanup completed successfully.'
exit 0