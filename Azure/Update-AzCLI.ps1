<#
.SYNOPSIS
  Update Azure CLI on Windows 11 Pro (MSI, pip, winget/Microsoft Store).

.DESCRIPTION
  - Detects installation method and updates Azure CLI using the appropriate mechanism.
  - Use Admin privileges (required for MSI/winget installs).
  - Exits with non-zero code on failure.

.USAGE
  Run in an elevated PowerShell:
    .\Update-AzureCLI.ps1
#>

# Ensure script runs elevated
function Test-IsElevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-IsElevated)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

Write-Host "Detecting Azure CLI installation..." -ForegroundColor Cyan

# Helper to run az --version and parse
function Get-AzCliVersion {
    try {
        $out = & az --version 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $out) { return $null }
        $firstLine = $out | Select-String -Pattern '^azure-cli\s' -SimpleMatch
        if ($firstLine) {
            $ver = ($firstLine -split '\s+')[1]
            return $ver
        }
        # fallback: find "azure-cli" in output
        $match = ($out | Where-Object { $_ -match 'azure-cli\s+([\d\.]+)' }) -replace '.*azure-cli\s+',''
        if ($match) { return $match.Trim() }
    } catch { return $null }
    return $null
}

$azVersion = Get-AzCliVersion
if (-not $azVersion) {
    Write-Warning "Azure CLI not found in PATH. If installed but not in PATH, update manually."
    exit 2
}
Write-Host "Current Azure CLI version: $azVersion"

# Detect installation source
$installMethod = $null

# 1) Check winget / Microsoft Store presence
try {
    $wingetList = winget list --id Microsoft.AzureCLI -s msstore 2>$null
    if ($LASTEXITCODE -eq 0 -and $wingetList -match 'Microsoft.AzureCLI') {
        $installMethod = 'winget-msstore'
    } else {
        # winget generic check
        $wingetListAll = winget list --id Microsoft.AzureCLI 2>$null
        if ($LASTEXITCODE -eq 0 -and $wingetListAll -match 'Microsoft.AzureCLI') {
            $installMethod = 'winget'
        }
    }
} catch { }

# 2) Check MSI (Program Files or registry)
if (-not $installMethod) {
    # Registry uninstall keys
    $keys = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($k in $keys) {
        Get-ChildItem $k -ErrorAction SilentlyContinue | ForEach-Object {
            $dn = ($_ | Get-ItemProperty -ErrorAction SilentlyContinue).DisplayName
            if ($dn -and $dn -match 'Azure CLI') {
                $installMethod = 'msi'
            }
        }
    }
}

# 3) Check pip (python) install
if (-not $installMethod) {
    try {
        $pipShow = & pip show azure-cli 2>$null
        if ($pipShow) { $installMethod = 'pip' }
    } catch { }
}

# 4) default to manual / unknown
if (-not $installMethod) { $installMethod = 'unknown' }

Write-Host "Detected install method: $installMethod"

switch ($installMethod) {
    'winget-msstore' {
        Write-Host "Updating Azure CLI via winget (Microsoft Store source)..." -ForegroundColor Green
        $proc = Start-Process -FilePath winget -ArgumentList 'upgrade','--id','Microsoft.AzureCLI','-e','--silent' -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -eq 0) { Write-Host "Azure CLI updated successfully (winget msstore)." ; exit 0 }
        else { Write-Error "winget update failed with exit code $($proc.ExitCode)." ; exit 3 }
    }
    'winget' {
        Write-Host "Updating Azure CLI via winget..." -ForegroundColor Green
        $proc = Start-Process -FilePath winget -ArgumentList 'upgrade','--id','Microsoft.AzureCLI','-e' -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -eq 0) { Write-Host "Azure CLI updated successfully (winget)." ; exit 0 }
        else { Write-Error "winget update failed with exit code $($proc.ExitCode)." ; exit 3 }
    }
    'msi' {
        Write-Host "Detected MSI installation. Downloading latest MSI and installing..." -ForegroundColor Green
        $msiUrl = 'https://aka.ms/installazurecliwindows'  # redirects to latest MSI
        $tmp = Join-Path $env:TEMP "AzureCLI-latest.msi"
        try {
            Write-Host "Downloading MSI from $msiUrl ..."
            Invoke-WebRequest -Uri $msiUrl -OutFile $tmp -UseBasicParsing -ErrorAction Stop
            Write-Host "Running MSI installer..."
            $proc = Start-Process -FilePath msiexec.exe -ArgumentList "/i","`"$tmp`"","/qn","/norestart" -Wait -NoNewWindow -PassThru
            if ($proc.ExitCode -eq 0) { Write-Host "Azure CLI updated successfully (MSI)." ; Remove-Item $tmp -ErrorAction SilentlyContinue ; exit 0 }
            else { Write-Error "msiexec failed with exit code $($proc.ExitCode)." ; Remove-Item $tmp -ErrorAction SilentlyContinue ; exit 4 }
        } catch {
            Write-Error "Failed to download or run MSI: $_"
            exit 5
        }
    }
    'pip' {
        Write-Host "Updating Azure CLI installed via pip..." -ForegroundColor Green
        try {
            # Prefer pip3 if available
            $pipCmd = 'pip'
            if (Get-Command pip3 -ErrorAction SilentlyContinue) { $pipCmd = 'pip3' }
            $proc = Start-Process -FilePath $pipCmd -ArgumentList 'install','--upgrade','azure-cli' -NoNewWindow -Wait -PassThru
            if ($proc.ExitCode -eq 0) { Write-Host "Azure CLI updated successfully (pip)." ; exit 0 }
            else { Write-Error "pip update failed with exit code $($proc.ExitCode)." ; exit 6 }
        } catch {
            Write-Error "pip update failed: $_"
            exit 7
        }
    }
    'unknown' {
        Write-Warning "Could not detect a known installation method. Attempting winget upgrade and MSI fallback..."
        # Try winget first
        try {
            $proc = Start-Process -FilePath winget -ArgumentList 'upgrade','--all' -NoNewWindow -Wait -PassThru -ErrorAction Stop
            if ($proc.ExitCode -eq 0) { Write-Host "winget attempted upgrades. Check az version." ; exit 0 }
        } catch { }
        # MSI fallback
        try {
            $msiUrl = 'https://aka.ms/installazurecliwindows'
            $tmp = Join-Path $env:TEMP "AzureCLI-latest.msi"
            Invoke-WebRequest -Uri $msiUrl -OutFile $tmp -UseBasicParsing -ErrorAction Stop
            Start-Process -FilePath msiexec.exe -ArgumentList "/i","`"$tmp`"","/qn","/norestart" -Wait -NoNewWindow -PassThru | Out-Null
            Remove-Item $tmp -ErrorAction SilentlyContinue
            Write-Host "MSI installer run; verify az --version."
            exit 0
        } catch {
            Write-Error "Automatic update failed. Please update Azure CLI manually from https://learn.microsoft.com/cli/azure/install-azure-cli-windows"
            exit 8
        }
    }
}

# End
