# Script to collect system information

# Get processor information
$Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors

# Get memory information
$Memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, MemoryType, @{Name='CapacityGB';Expression={[math]::Round($_.Capacity/1GB,2)}}
$TotalMemory = ($Memory.Capacity | Measure-Object -Sum).Sum / 1GB

# Get disk information
$DiskInfo = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, MediaType, Size, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}
$Volumes = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID, FileSystem, @{Name='FreeSpaceGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}

# Get operating system information
$OS = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, @{Name='TotalVisibleMemoryGB';Expression={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{Name='FreePhysicalMemoryGB';Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}}

# Output results
Write-Output "Processor Information:"
$Processor | Format-Table -AutoSize

Write-Output "\nMemory Information:"
$Memory | Format-Table -AutoSize
Write-Output "Total Installed Memory (GB): $([math]::Round($TotalMemory,2))\n"

Write-Output "Disk Information:"
$DiskInfo | Format-Table -AutoSize

Write-Output "\nVolume Information:"
$Volumes | Format-Table -AutoSize

Write-Output "\nOperating System Information:"
$OS | Format-Table -AutoSize
