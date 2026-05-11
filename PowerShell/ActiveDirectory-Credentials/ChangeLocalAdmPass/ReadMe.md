# <img src="../../../Assets/ADirectoryLogo.svg" width="245" alt="PowerShell"> Logon password chages script

[![Windows Server](https://custom-icon-badges.demolab.com/badge/Windows%20Server-Microsoft-0078D6?style=flat&logo=ms-windows-server&logoColor=white)](https://www.microsoft.com/en-us/windows-server/)
[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-PowerShell-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

There is a **powershell** logon script that can be used for finding and changing a local admiin password on **Windows** systems from **Windows 7** up to **Windows 11** in a Windows domain environment.

## 📂 Description

- [**Logon script Change-LMAdmPass.ps1**](Change-LMAdmnPass.ps1)
  - this script finds and changes a the password for local admin and if this account disable just enable it
  - Use GPO Startup Script instead of Logon Script
    - Computer Configuration
      - Policies
        - Windows Settings
          - Scripts (Startup/Shutdown)
  - run this script with parameters:
  ```powershell

  ```        
- [**Ecrypt sensitive data Create-EncData.ps1**](./Create-EncData.ps1)
  - this script encrypt sensitive data where the new password keeps
  - run this script with parameters:
  ```powershell

  ```

- [**Create key for encryption Create-EncKey.ps1**](./Create-EncKey.ps1)
  - this script creates an encryption key for encrypting the data
  - run this script with parameters:
  ```powershell

  ```

- **Permissions**: for folders where an encrypted key and an encrypted password are kept
  - **Domain Computers** → `Read`
  - `remove` **Authenticated Users**
  - `remove` **Everyone**

---

🔙 [back to 📂 Powershell](../)
