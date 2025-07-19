# Parameters
$baseMountPath = "C:\Mounts\VMData"
$vhdsSizeGB = 45
$vhdsName = "VM.vhdx"

# Ensure base mount path exists
New-Item -ItemType Directory -Path $baseMountPath -Force | Out-Null

# Get all volumes with FileSystemLabel starting with "0"
$volumes = Get-Volume | Where-Object { $_.FileSystemLabel -match '^0' }

foreach ($volume in $volumes) {
    $label = $volume.FileSystemLabel
    $mountPath = Join-Path $baseMountPath $label
    $vhdsPath = Join-Path $mountPath $vhdsName

    # Create mount folder
    New-Item -ItemType Directory -Path $mountPath -Force | Out-Null

    # Get the corresponding partition
    $partition = Get-Partition | Where-Object {
        $_.GptType -ne $null -and $_.AccessPaths.Count -eq 0 -and $_.DriveLetter -eq $null -and $_.Size -eq $volume.Size
    }

    if ($partition) {
        try {
            Add-PartitionAccessPath -DiskNumber $partition.DiskNumber -PartitionNumber $partition.PartitionNumber -AccessPath $mountPath
        } catch {
            Write-Warning "Failed to mount label '$label' to $mountPath"
            continue
        }
    }

    # Create VHDX if not exists
    if (-not (Test-Path $vhdsPath)) {
        Write-Host "Creating VHDX for label '$label' at $vhdsPath ..."
        New-VHD -Path $vhdsPath -SizeBytes ($vhdsSizeGB * 1GB) -Dynamic | Out-Null
    } else {
        Write-Host "VHDX already exists at $vhdsPath"
    }
}

Write-Host "`nAll operations completed."
