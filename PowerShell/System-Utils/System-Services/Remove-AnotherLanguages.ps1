$LanguageList = Get-WinUserLanguageList
$Language = $LanguageList | where LanguageTag -eq "qaa-Latn"
$LanguageList.Remove($Language)
Set-WinUserLanguageList $LanguageList -Force