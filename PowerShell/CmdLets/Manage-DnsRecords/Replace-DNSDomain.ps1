param(
    [Parameter(Mandatory)]
    [string]$File,

    [Parameter(Mandatory)]
    [string]$OldDomain,

    [Parameter(Mandatory)]
    [string]$NewDomain
)

$OutputFile = Join-Path `
    (Split-Path $File) `
    "$NewDomain.csv"

$Pattern = [regex]::Escape($OldDomain)

(Get-Content $File -Raw) `
    -replace $Pattern, $NewDomain |
    Set-Content $OutputFile -Encoding utf8

Write-Host "[OK] Created: $OutputFile" -ForegroundColor Green