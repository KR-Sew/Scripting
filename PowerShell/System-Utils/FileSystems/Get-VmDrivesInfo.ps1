Param(
    [Parameter(Mandatory=$true)]
    [string[]]$VMName    
)
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}
# Define the script block to run remotely
$ScriptBlock = {
    Get-Disk | Select-Object Number, FriendlyName, SerialNumber, Size, OperationalStatus, PartitionStyle
}

foreach ($Computer in $VMName) {
    Write-Host "`n===== $Computer =====" -ForegroundColor Cyan
    try {
        Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -ErrorAction Stop
    } catch {
        Write-Warning "Failed to connect to '$Computer': $_"
    }
}