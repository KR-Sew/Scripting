# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> WinRM MaxEvelopeSize fixed script  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

**WinRM** `MaxEnvelopeSize` error when managing via the **Server Manager** snap-in.
Useful `PowerShell` scripts for fixing error that happens with default size value.  

## 📂 Description

- 📂 [Set **WinRM** `MaxEvelopeSize` value](./Set-WinRMMaxEnvelopeSize.ps1)

  the script changes `MaxEnvelopeSize`, restarts **WinRM**, waits for it to return to `Running`, and displays the confirmed applied value.
  - To specify another value:
  
  ```powershell
     .\Set-WinRMMaxEnvelopeSize.ps1 -MaxEnvelopeSizeKB 16384
  ```

- 📄[README.md](ReadMe.md)                   # Project documentation

---

🔙 [back to 📂 Powershell](../)
