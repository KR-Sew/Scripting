<#
.SYNOPSIS
    Install or Update AWS CLI v2 on Windows
#>

param(
    [switch]$Force
)

# ================================
# Logging Functions (Your Style)
# ================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","OK","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $time = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

    switch ($Level) {
        "INFO"  { $color = "Cyan" }
        "OK"    { $color = "Green" }
        "WARN"  { $color = "Yellow" }
        "ERROR" { $color = "Red" }
    }

    Write-Host "[$time][$Level] $Message" -ForegroundColor $color
}

# ================================
# Detect Installed Version
# ================================

function Get-AwsVersion {
    try {
        $versionOutput = aws --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            if ($versionOutput -match "aws-cli\/([0-9\.]+)") {
                return $Matches[1]
            }
        }
    } catch {}
    return $null
}

# ================================
# Main Logic
# ================================

Write-Log "Checking AWS CLI installation..."

$installedVersion = Get-AwsVersion

if ($installedVersion) {
    Write-Log "Detected AWS CLI version $installedVersion" "OK"
} else {
    Write-Log "AWS CLI not installed." "WARN"
}

$installerUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$tempFile = "$env:TEMP\AWSCLIV2.msi"

if (-not $installedVersion -or $Force) {

    Write-Log "Downloading latest AWS CLI v2..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $tempFile -UseBasicParsing

    Write-Log "Installing AWS CLI silently..."
    Start-Process msiexec.exe -ArgumentList "/i `"$tempFile`" /qn" -Wait

    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

    $newVersion = Get-AwsVersion

    if ($newVersion) {
        Write-Log "AWS CLI installed successfully. Version: $newVersion" "OK"
    } else {
        Write-Log "Installation failed." "ERROR"
        exit 1
    }
}
else {
    Write-Log "AWS CLI already installed. Use -Force to reinstall." "INFO"
}