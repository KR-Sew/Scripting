Param(
    [Parameter(Mandatory=$true)]
    [string[]]$VMName,
    [Parameter()]
    [pscredential]$Credential    
)

foreach ($name in $VMName) {
    $vm = Get-VM -Name $name -ErrorAction SilentlyContinue

    if (-not $vm) {
        Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
        continue
    }

    Write-Host "`nVM Name: $($vm.Name)" -ForegroundColor Cyan

    $disks = Get-VMHardDiskDrive -VMName $vm.Name

    foreach ($disk in $disks) {
        $vhd = Get-VHD -Path $disk.Path

        [PSCustomObject]@{
            VMName             = $vm.Name
            Controller         = $disk.ControllerType
            ControllerNumber   = $disk.ControllerNumber
            ControllerLocation = $disk.ControllerLocation
            DiskPath           = $disk.Path
            VHDFormat          = $vhd.VHDFormat
            VHDType            = $vhd.VHDType
            SizeGB             = [math]::Round($vhd.Size / 1GB, 2)
            FileSizeGB         = [math]::Round($vhd.FileSize / 1GB, 2)
        }
    }
}
