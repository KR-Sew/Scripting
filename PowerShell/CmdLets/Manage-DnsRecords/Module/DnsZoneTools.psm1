$private = Join-Path $PSScriptRoot 'Private'
$public  = Join-Path $PSScriptRoot 'Public'
Get-ChildItem $private -Filter '*.ps1' -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem $public  -Filter '*.ps1' -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Export-ModuleMember -Function Export-DnsZoneCsv,Import-DnsZoneCsv,Convert-DnsZoneCsv,New-DnsZoneSafe
