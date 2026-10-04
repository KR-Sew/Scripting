# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> Manage DHCP reservations CmdLets  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

PowerShell Custom cmdlets for managing **DHCP** reservations such as `Export` and `Import` **dhcp** reservation

## 📂 Description

- 📄 [**`Create-DhcpReservation`**](./Create-DhcpScope.ps1)
- 📄 [**`Export-DhcpReservation.ps1`**](./Export-DhcpReservation.ps1)
- 📄 [**`Import-DhcpReservation.ps1`**](./Import-DhcpReservation.ps1)
- 📂 [**`Module`**](./Module/)
  - It contains:
   ```plain text
      DhcpAdminTools/
      ├── DhcpAdminTools.psd1
      ├── DhcpAdminTools.psm1
      ├── README.md 
      │
      ├── Public/
      │   ├── New-DhcpScopeSafe.ps1
      │   ├── Export-DhcpReservation.ps1
      │   └── Import-DhcpReservation.ps1
      │
      ├── Private/
      │   ├── Test-DhcpAdminPrerequisite.ps1
      │   └── Test-IPv4Address.ps1
      │
      └── examples/
          ├── New-Scope.ps1
          └── Migrate-Reservations.ps1
    ```

  - Installing the module:
  
   ```powershell
     cd .\DhcpAdminTools
     Import-Module .\DhcpAdminTools.psd1 -Force -Verbose
     Get-Command -Module DhcpAdminTools
   ```

  - After installing the module:
   
   ```powershell
      Import-Module DhcpAdminTools
      Get-Command -Module DhcpAdminTools
      Get-Help New-DhcpScopeSafe -Full
      Get-Help Export-DhcpReservation -Examples
    ```

- 📄 [README.md](ReadMe.md)

---

🔙 [back to 📂 Powershell](../)
