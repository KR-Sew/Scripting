# Examples

```powershell
Import-Module ..\DnsZoneTools.psd1 -Force

# Export
Export-DnsZoneCsv -ZoneName 'u-booking.ru' -Path '.\u-booking.ru.csv'

# Rename FQDN references without Excel touching delimiters
Convert-DnsZoneCsv -Path '.\u-booking.ru.csv' -OldDomain 'u-booking.ru' -NewDomain 'example.net' -OutputPath '.\example.net.csv'

# Preview import
Import-DnsZoneCsv -ZoneName 'example.net' -Path '.\example.net.csv' -WhatIf

# Import and ask how to create the zone if it is missing
Import-DnsZoneCsv -ZoneName 'example.net' -Path '.\example.net.csv'

# Non-interactive AD-integrated zone creation if missing
Import-DnsZoneCsv -ZoneName 'lab.example.net' -Path '.\lab.example.net.csv' -IfZoneMissing ADDomain
```
