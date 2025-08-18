# <img src="../../../../Assets/Powershell.svg" width="35" alt="PowerShell"> Manage-RDPSetting Powershell script  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

The script can check, enabble or disable RDP on Windows sytstem

### Script can be run with the next keys

- `-Status` this key shows current configuration for RDP protocol in a system
- `-Emable` this key set up to enalbe RDP protocol and allow firewall rules
- `-Disable` this key set up to disable RDP protocol and disable firewall rules

  #### Aslo script can runs with to keys such as

- `-Enable` and `-Status`, `-Disable` and `-status`

---

#### Usage

- #### Enable RDP

  ```powershell
   .\Manage-RDP.ps1 -Enable
   ```

- #### Disable RDP

  ```powershell
    .\Manage-RDP.ps1 -Disable
   ```

- #### Check status RDP

    ```powershell
    .\Manage-RDP.ps1 -Status
    ```

- #### Emable and status

    ```powershell
    .\Manage-RDP.ps1 -Enable -Status
    ```

- #### Disable and Status

    ```powershell
    .\Manage-RDP.ps1 -Disable -Status
    ```

---

🔙 [back to 📂 System Utilities](../)
