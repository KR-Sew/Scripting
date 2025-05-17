Param (
    [Parameter(Mandatory=$True)]
    [string]$folderName
)
$sourceFolder = Get-ChildItem -Path $folderName -Recurse 
  Sort-Object $sourceFolder Length -Descending | Select-Object -First 25 LastWriteTime,Directory,Name, @{Name='Size (MB)'; Expression={[math]::round($_.Length / 1MB, 2)}} | Format-Tab
le -AutoSize