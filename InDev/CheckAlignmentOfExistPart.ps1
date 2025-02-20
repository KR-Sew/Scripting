#You can also use PowerShell to check the alignment of existing partitions

Get-Partition | Select-Object PartitionNumber, DriveLetter, Size, @{Name="Alignment";Expression={[math]::round($_.Offset/1MB, 2)}}

#Check Free Space on a Specific Disk: To check the free space on a specific disk, you can use the following command. Replace 1 with the appropriate disk number
Get-Disk -Number 1 | Select-Object -Property Number, Size, PartitionStyle, @{Name="FreeSpace(GB)";Expression={[math]::round($_.Size - ($_.Partitions | Measure-Object -Property Size -Sum).Sum, 2) / 1GB}}
