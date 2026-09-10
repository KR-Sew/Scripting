# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> Account management scripts  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

 These scripts facilitate the automation of tasks such as creating, modifying, and deleting user accounts and groups, as well as assigning and revoking access rights.

## 📂 Description

- 📄[**Set local user password**](./SetLocalUserPassword.ps1)
  - Set local user password running this script using `secure string` to protect credentials.
    Just running it you will be promted to input credentials `user name` and `new password`.
- 📄[**Find Privilege Group Changes**](./Watch-PrivilegeGroupChanges.ps1)
  - Find privilege group changes by `Event ID` in `Security` EventLog ID `4728`, `4729`
 
---

🔙 [back to 📂 System utilities](../)
