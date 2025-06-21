# Safe removal of MDaemon LDAP address book
$regPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\LDAP\"

# Check if the key exists first
if (Test-Path $regPath) {
    $entries = Get-ChildItem -Path $regPath

    foreach ($entry in $entries) {
        $dispName = (Get-ItemProperty -Path $entry.PSPath).DisplayName
        if ($dispName -eq "MDaemon Address Book") {
            Remove-Item -Path $entry.PSPath -Recurse -Force
            Write-Host "✅ Removed LDAP address book: $dispName"
        }
    }
} else {
    Write-Host "ℹ️ No LDAP address books found – nothing to remove."
}
