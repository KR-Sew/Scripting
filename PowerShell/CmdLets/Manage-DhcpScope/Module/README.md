# DhcpAdminTools
[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)


A small Windows PowerShell module for repeatable DHCPv4 administration.

## Commands

- `New-DhcpScopeSafe` — safely creates a DHCPv4 scope and common scope options.
- `Export-DhcpReservation` — exports reservations from one or more scopes to CSV.
- `Import-DhcpReservation` — restores exported reservations, either to their original scopes or to one destination scope.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7 on Windows.
- Microsoft `DhcpServer` module / DHCP management tools (RSAT-DHCP).
- Sufficient permissions on the target DHCP server.

## Install

For the current user, copy the complete `DhcpAdminTools` directory to:

```powershell
$HOME\Documents\WindowsPowerShell\Modules\DhcpAdminTools
```

For PowerShell 7, a common per-user location is:

```powershell
$HOME\Documents\PowerShell\Modules\DhcpAdminTools
```

Then load it:

```powershell
Import-Module DhcpAdminTools -Force
Get-Command -Module DhcpAdminTools
```

## Create a scope

Always preview first:

```powershell
New-DhcpScopeSafe `
    -ComputerName V08 `
    -Name 'Servers VLAN 205' `
    -ScopeId 10.10.205.0 `
    -StartRange 10.10.205.10 `
    -EndRange 10.10.205.240 `
    -SubnetMask 255.255.255.0 `
    -Router 10.10.205.254 `
    -DnsServers 10.0.0.10,10.0.0.11 `
    -DomainName vezu.ru `
    -WhatIf
```

Remove `-WhatIf` when the preview is correct.

## Export reservations

```powershell
Export-DhcpReservation `
    -ComputerName V08 `
    -ScopeId 10.10.204.0,10.10.205.0 `
    -Path .\reservations.csv `
    -Verbose
```

CSV columns are kept intentionally simple:

`ScopeId, IPAddress, ClientId, Name, Description, Type`

## Import reservations

Restore each row to the original scope stored in the CSV:

```powershell
Import-DhcpReservation `
    -ComputerName V08 `
    -Path .\reservations.csv `
    -WhatIf
```

Redirect every row to a different scope:

```powershell
Import-DhcpReservation `
    -ComputerName V08 `
    -Path .\reservations.csv `
    -DestinationScope 10.10.205.0 `
    -WhatIf
```

Existing IP reservations are skipped by default. Add `-ErrorOnExisting` if you want an error instead.

## Useful checks

```powershell
Test-ModuleManifest .\DhcpAdminTools.psd1
Import-Module .\DhcpAdminTools.psd1 -Force
Get-Command -Module DhcpAdminTools
Get-Help New-DhcpScopeSafe -Full
Get-Help Export-DhcpReservation -Examples
Get-Help Import-DhcpReservation -Examples
```

## Design notes

The module uses native advanced-function behavior rather than custom `Write-Host` logging. Use `-Verbose` for operational detail and `-WhatIf`/`-Confirm` for change control. `New-DhcpScopeSafe` also verifies that `ScopeId` is the network calculated from `StartRange` and `SubnetMask`, which helps catch accidental scope definitions before changes are made.
