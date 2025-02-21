# Check current Docker version
docker --version

# Uninstall the current Docker version
$dockerInstallerPath = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
if (Test-Path $dockerInstallerPath) {
    Start-Process -FilePath $dockerInstallerPath -ArgumentList "uninstall" -Wait
}

# Download the latest Docker Desktop installer
$dockerInstallerUrl = "https://desktop.docker.com/win/stable/Docker Desktop Installer.exe"
$downloadPath = "D:\tmp\Docker Desktop Installer.exe"
Invoke-WebRequest -Uri $dockerInstallerUrl -OutFile $downloadPath

# Install the latest Docker Desktop
Start-Process -FilePath $downloadPath -ArgumentList "install" -Wait

# Cleanup
Remove-Item -Path $downloadPath

# Verify the installation
docker --version
