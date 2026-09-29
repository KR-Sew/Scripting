# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> PowerShell Scripts Collection  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

The scripts enable users to start, stop, and restart services, gather hardware and software details, and modify system settings to optimize performance and functionality  

## 📂 Folder Description

- 📄[Check and install RSAT](./CheckAndInstallRSAT.ps1) # automated RSAT installation
- 📄[Get Powershell version](./getCurrentPwshellVersion.ps1) # Get current Powershell verion
- 📄[Get network adapter info](./GetHostNetworkAdapter.ps1) # Get network adapter information
- 📄[Get motherboard info](./getMotherBoard.ps1) # Get motehreboard information
- 📄[Get system info](./GetSystemInfo.ps1) # Get system information
- 📄[Get team properties](./GetTeamProperties.ps1) # Get team network adapter properties
- 📄[Restart service](./RestartService.ps1) # Restart service(service name as a parameter)
- 📄[Jpdate Docker on Windows server](./Update-Docker-WinServ.ps1) # Update Docker on Windows server
- 📄[Update RClone on Windows system](./UpdateRCloneWiindows.ps1) # Update Rclone storage menagement software on Windows
- 📄[Manage-IPv6Binding.ps1](./Manage-IPv6Binding.ps1)
  - It can be useful script in case when you use **6to4** tunnel from **HE**(Hurricane Electric)
  
  ```powershell
     # Get current status on all network adapters
    .\Manage-IPv6Binding.ps1 -Action Status
     # to disable IPv6 
    .\Manage-IPv6Binding.ps1 -Action Disable -AdapterName Ethernet
     # to enable IPv6
    .\Manage-IPv6Binding.ps1 -Action Enable -AdapterName Ethernet
  ```

- 📄[About this section](./ReadMe.md)

---

🔙 [back to 📂 System Utilities](../)
