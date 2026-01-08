<#
.SYNOPSIS
  Update Azure CLI on Windows only if newer version exists.

.DESCRIPTION
  Step-based, function-driven script with logging and install method detection.

.REQUIRES
  - Run as Administrator
#>

# ================== CONFIG ==================

$ScriptName = "Update-AzureCLI"
$LogDir     = "$env:ProgramData\Scripts\Logs"
$LogFile    = Join-Path $LogDir "$ScriptName-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# ================== LOGGING ==================

function Initialize-Logging {
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    "==== $ScriptName started: $(Get-Date) ====" | Out-File -FilePath $LogFile -Encoding utf8
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR","OK")]
        [string]$Level = "INFO"
    )

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts][$Level] $Message"

    switch ($Level) {
        "INFO"  { Write-Host $line -ForegroundColor Cyan }
        "OK"    { Write-Host $line -ForegroundColor Green }
        "WARN"  { Write-Host $line -ForegroundColor Yellow }
        "ERROR" { Write-Host $line -ForegroundColor Red }
    }

    $line | Out-File -FilePath $LogFile -Append -Encoding utf8
}

# ================== CHECKS ==================

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)

    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "Script must be run as Administrator." "ERROR"
        exit 5
    }

    Write-Log "Running with administrative privileges." "OK"
}
# find executable path
function Find-AzExecutable {
    $paths = @(
        "$env:ProgramFiles\Microsoft SDKs\Azure\CLI2\wbin\az.cmd",
        "$env:ProgramFiles\Azure\CLI2\wbin\az.cmd",
        "$env:LocalAppData\Microsoft\WindowsApps\az.cmd"  # Store version
    )

    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }

    return $null
}


# ================== VERSION ==================
function Get-LatestAzVersion {
    try {
        Write-Log "Querying latest Azure CLI version from Microsoft (GitHub)..."

        $headers = @{ "User-Agent" = "PowerShell" }
        $r = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/Azure/azure-cli/releases/latest" `
            -Headers $headers `
            -ErrorAction Stop

        # tag examples:
        # v2.80.0
        # azure-cli-2.81.0

        if ($r.tag_name -match '(\d+\.\d+\.\d+)') {
            return [version]$Matches[1]
        }
        else {
            throw "Unable to parse version from tag: $($r.tag_name)"
        }
    }
    catch {
        Write-Log "Failed to fetch latest version: $_" "ERROR"
        return $null
    }
}



function Get-InstalledAzVersion {
    try {
        $v = az version --output json | ConvertFrom-Json
        return [version]$v.'azure-cli'
    } catch {
        return $null
    }
}

function Get-InstalledAzVersion {
    param(
        [string]$AzPath = "az"
    )

    try {
        $out = & $AzPath version --output json 2>$null
        if (-not $out) { return $null }

        $v = $out | ConvertFrom-Json
        return [version]$v.'azure-cli'
    }
    catch {
        Write-Log "Azure CLI execution failed: $_" "WARN"
        return $null
    }
}


# ================== UNINSTALL METHOD ==================
function Remove-AzureCLI {
    Write-Log "Attempting to remove existing Azure CLI installation..."

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget uninstall --id Microsoft.AzureCLI --silent --accept-source-agreements 2>$null
    }

    Get-AppxPackage Microsoft.AzureCLI -ErrorAction SilentlyContinue |
        Remove-AppxPackage -ErrorAction SilentlyContinue

    Write-Log "Removal attempt completed."
}


# ================== INSTALL METHOD ==================

function Find-InstallMethod {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $pkg = winget list --id Microsoft.AzureCLI 2>$null
        if ($pkg -match "Microsoft.AzureCLI") { return "winget" }
    }

    if (Get-AppxPackage Microsoft.AzureCLI -ErrorAction SilentlyContinue) {
        return "store"
    }

    if (Get-Command pip -ErrorAction SilentlyContinue) {
        pip show azure-cli *> $null
          if ($LASTEXITCODE -eq 0) {
              return "pip"
           }
    }

    return "msi"
}

# ================== UPDATE METHODS ==================

function Update-WithWinget {
    Write-Log "Updating Azure CLI via winget..."
    winget upgrade --id Microsoft.AzureCLI --silent --accept-package-agreements --accept-source-agreements
}

function Update-WithStore {
    Write-Log "Updating Azure CLI via Microsoft Store (winget msstore)..."
    winget upgrade --id Microsoft.AzureCLI --source msstore --silent
}

function Update-WithPip {
    Write-Log "Updating Azure CLI via pip..."
    pip install --upgrade azure-cli
}

function Update-WithMSI {
    Write-Log "Updating Azure CLI using official MSI installer..."

    try {
        $url = "https://aka.ms/installazurecliwindows"
        $tmp = Join-Path $env:TEMP "AzureCLI-latest.msi"

        Write-Log "Downloading MSI package..."
        Invoke-WebRequest -Uri $url -OutFile $tmp -ErrorAction Stop

        Write-Log "Launching MSI installer..."
        Start-Process msiexec.exe `
            -ArgumentList "/i `"$tmp`" /qn /norestart" `
            -Wait -NoNewWindow

        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
    catch {
        Write-Log "MSI update failed: $_" "ERROR"
        exit 8
    }
}

# ================== MAIN FLOW ==================

Initialize-Logging
Write-Log "Starting Azure CLI update process..."

Assert-Admin

$installedVersion = Get-InstalledAzVersion
if ($installedVersion) {
    Write-Log "Installed version: $installedVersion" "OK"
} else {
    Write-Log "Azure CLI not detected. Fresh install will be attempted." "WARN"
}

$latestVersion = Get-LatestAzVersion
if (-not $latestVersion) {
    Write-Log "Cannot continue without latest version info." "ERROR"
    exit 6
}

Write-Log "Latest available version: $latestVersion"

$AzBroken = $false

$installedVersion = Get-InstalledAzVersion
if ($installedVersion) {
    Write-Log "Installed version: $installedVersion" "OK"
}
else {
    Write-Log "Azure CLI not detected or broken." "WARN"
    $AzBroken = $true
}


if ($installedVersion -and $installedVersion -ge $latestVersion) {
    Write-Log "Azure CLI is already up to date. No update required." "OK"
    exit 0
}

Write-Log "Update required. Detecting installation method..."

if ($AzBroken) {
    Write-Log "Broken installation detected. Performing cleanup before reinstall." "WARN"
    Remove-AzureCLI
    $method = "msi"   # force clean install
}
else {
    $method = Find-InstallMethod
}

Write-Log "Detected installation method: $method"

switch ($method) {
    "winget" { Update-WithWinget }
    "store"  { Update-WithStore }
    "pip"    { Update-WithPip }
    "msi"    { Update-WithMSI }
    default  { Update-WithMSI }
}

Start-Sleep -Seconds 3

$azPath = Find-AzExecutable
if (-not $azPath) {
    Write-Log "Azure CLI executable not found in known install paths." "ERROR"
    exit 10
}

$newVersion = Get-InstalledAzVersion -AzPath $azPath

if ($newVersion) {
    Write-Log "Version after update: $newVersion" "OK"

    if ($newVersion -ge $latestVersion) {
        Write-Log "Azure CLI successfully updated." "OK"
        exit 0
    } else {
        Write-Log "Update executed but version did not change." "WARN"
        exit 9
    }
}

Write-Log "Azure CLI not detected after update." "ERROR"
exit 10
