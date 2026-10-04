$private = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -File -ErrorAction SilentlyContinue)
$public  = @(Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public')  -Filter '*.ps1' -File -ErrorAction SilentlyContinue)

foreach ($file in @($private + $public)) {
    try { . $file.FullName }
    catch { throw "Failed to import $($file.FullName): $($_.Exception.Message)" }
}

Export-ModuleMember -Function $public.BaseName
