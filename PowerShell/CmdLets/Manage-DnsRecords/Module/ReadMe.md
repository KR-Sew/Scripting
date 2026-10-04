# <img src="../../../../Assets/Powershell.svg" width="35" alt="PowerShell"> DnsZoneTools

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Small PowerShell module for repeatable Windows DNS zone migrations in a lab or administrative environment.

## What it solves

The module keeps the workflow deliberately simple:

```text
Windows DNS
   -> Export-DnsZoneCsv
   -> CSV
   -> optional Convert-DnsZoneCsv / manual text edit
   -> Import-DnsZoneCsv
   -> Windows DNS
```

It was built around real migration issues: SRV records, AD-integrated vs file-backed zones, duplicate imports, malformed CSV files, and Excel changing CSV delimiters/quoting.

## Commands

| Command | Purpose |
|---|---|
| `Export-DnsZoneCsv` | Export A, AAAA, CNAME, MX, TXT and SRV records to CSV. SOA/NS are excluded. |
| `Convert-DnsZoneCsv` | Replace an old domain with a new domain in record Data while preserving the CSV format. |
| `New-DnsZoneSafe` | Create a file-backed, AD Domain-replicated, or AD Forest-replicated primary zone. |
| `Import-DnsZoneCsv` | Validate and import the CSV; optionally create a missing zone. |

## Requirements

- **Windows Server** or **Windows** with **RSAT DNS** tools
- `DnsServer` PowerShell module
- Administrative permissions on the target **DNS** server
- **PowerShell** `5.1+` supported by the manifest

## Install for the current session

From the repository directory:

```powershell
Import-Module .\DnsZoneTools.psd1 -Force
Get-Command -Module DnsZoneTools
```

To install it persistently, copy the `DnsZoneTools` directory into a path listed by:

```powershell
$env:PSModulePath -split ';'
```

## CSV contract

The module deliberately uses **comma** as the `CSV` delimiter:

```csv
"HostName","RecordType","TTL","Data"
"@","A","3600","10.0.0.15"
"@","MX","3600","10;mail.example.net."
"_imap._tcp","SRV","3600","10;0;993;imap.example.net."
"autodiscover","CNAME","3600","mail.example.net."
```

Internal Data separators are:

- **MX**: `preference;target`
- **SRV**: `priority;weight;port;target`
- **TXT** chunks: separated by `|`

Do **not** use Excel to casually edit/save these files. Excel can rewrite CSV quoting or use a regional semicolon delimiter. Prefer VS Code, Notepad++, PowerShell, or `Convert-DnsZoneCsv`.

## Export

```powershell
Export-DnsZoneCsv `
    -ZoneName 'u-booking.ru' `
    -Path '.\u-booking.ru.csv'
```

Remote DNS server:

```powershell
Export-DnsZoneCsv `
    -ComputerName 'V08' `
    -ZoneName 'u-booking.ru' `
    -Path '.\u-booking.ru.csv'
```

The exporter validates the resulting CSV by importing it back and checking for the four required columns.

## Rename domain references safely

Instead of Excel Find/Replace:

```powershell
Convert-DnsZoneCsv `
    -Path '.\u-booking.ru.csv' `
    -OldDomain 'u-booking.ru' `
    -NewDomain 'example.net' `
    -OutputPath '.\example.net.csv'
```

This intentionally changes the `Data` field only. Relative `HostName` values normally remain unchanged when cloning one zone to another. For sub-zone consolidation, edit `HostName` explicitly as required.

## Create a DNS zone

File-backed primary:

```powershell
New-DnsZoneSafe -ZoneName 'example.net' -ZoneStorage File
```

AD-integrated, replicated in the current domain:

```powershell
New-DnsZoneSafe -ZoneName 'example.net' -ZoneStorage ADDomain
```

AD-integrated, replicated forest-wide:

```powershell
New-DnsZoneSafe -ZoneName 'example.net' -ZoneStorage ADForest
```

Use `-WhatIf` to preview creation.

## Import

```powershell
Import-DnsZoneCsv `
    -ZoneName 'example.net' `
    -Path '.\example.net.csv'
```

The CSV is validated **before** a missing DNS zone is created. If the zone does not exist, the default interactive menu is:

```text
[1] File-based primary zone
[2] AD-integrated, Domain replication
[3] AD-integrated, Forest replication
[Q] Quit
```

For unattended use:

```powershell
Import-DnsZoneCsv `
    -ZoneName 'example.net' `
    -Path '.\example.net.csv' `
    -IfZoneMissing ADDomain
```

Preview record creation:

```powershell
Import-DnsZoneCsv `
    -ZoneName 'example.net' `
    -Path '.\example.net.csv' `
    -WhatIf
```

## Duplicate behavior

The importer checks `HostName + RecordType`. If a record of the same type already exists at that name, it is skipped rather than causing the rerun to fail.

This is intentionally conservative. Version 1.0 does not overwrite existing DNS data.

## SRV records

Windows does not provide an `Add-DnsServerResourceRecordSRV` cmdlet. The module uses the generic command correctly:

```powershell
Add-DnsServerResourceRecord -Srv ...
```

## AD-integrated zones

`New-DnsZoneSafe` supports:

- `ADDomain` -> `ReplicationScope Domain`
- `ADForest` -> `ReplicationScope Forest`

Secure dynamic updates are used by default for AD-integrated zones. File-backed zones default to no dynamic updates.

## Sub-zone consolidation example

Suppose the old authoritative zone is:

```text
mail.manyhands.pro
```

and its records are being moved into:

```text
manyhands.pro
```

A relative record such as:

```text
@             A      10.0.0.15
_tcp._imap    SRV    0;0;993;mail.manyhands.pro.
```

must be edited for the parent zone as appropriate, for example:

```text
mail              A      10.0.0.15
_tcp._imap.mail   SRV    0;0;993;mail.manyhands.pro.
```

The target FQDN in SRV/MX/CNAME Data can remain unchanged when the externally visible name is not changing.

## Recommended workflow

```powershell
Import-Module .\DnsZoneTools.psd1 -Force

Export-DnsZoneCsv `
    -ZoneName 'old.example.net' `
    -Path '.\old.example.net.csv'

Convert-DnsZoneCsv `
    -Path '.\old.example.net.csv' `
    -OldDomain 'old.example.net' `
    -NewDomain 'new.example.net' `
    -OutputPath '.\new.example.net.csv'

Import-DnsZoneCsv `
    -ZoneName 'new.example.net' `
    -Path '.\new.example.net.csv' `
    -WhatIf

Import-DnsZoneCsv `
    -ZoneName 'new.example.net' `
    -Path '.\new.example.net.csv'
```

## Safety notes

- **SOA** records are not migrated.
- **NS** records are not exported because a newly-created zone receives its own authoritative infrastructure records.
- `CSV` structure is validated before **DNS** changes.
- Existing records are not overwritten.
- Prefer `-WhatIf` before a new migration.
- Keep the original exported `CSV` as a backup.

🔙 [back to 📂 **Manage-DnsRecords**](../)