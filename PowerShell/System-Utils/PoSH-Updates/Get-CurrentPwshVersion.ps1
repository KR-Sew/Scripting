Write-Host "The current version of PowerShell is :"

$Value01 = Get-Command powershell | Select-Object Version
$Value02 = Get-Host | Select-Object Version
$customTable = [PSCustomObject]@{
    Major = $PSVersionTable.PSVersion.Major
    Minor = $PSVersionTable.PSVersion.Minor
    Patch = $PSVersionTable.PSVersion.Patch
    Version = $Value01.Version
    Year = $Value02.Version
}
$customTable | Format-Table -AutoSize