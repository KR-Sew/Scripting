# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> PowerShell CmdLet Select-GitEmoCommit

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Run Script on Push](https://github.com/KR-Sew/Scripting/actions/workflows/bash.yml/badge.svg)](https://github.com/KR-Sew/Scripting/actions/workflows/bash.yml)

This cmdlet works with git and add emoji to the description of the commit.

## 📂 Folder contents  

- 📄 [Select-GitEmoCommit.ps1](Select-GitEmoCommit.ps1) # CmdLet
- 📄 [Emoji-config.json](emoji-config.json) # Collection of commit emoji  
- 📄 [About this section](ReadMe.md) # Project documentation

---
To make your Commit-GitChanges cmdlet available in every PowerShell session, follow these steps:

1. Save the Module in a Persistent Location

Move your PowerShell script (Commit-GitChanges.psm1) and emoji-config.json to a dedicated module directory. PowerShell expects custom modules in one of these locations:

User scope:

```powershell
$env:USERPROFILE\Documents\PowerShell\Modules\Commit-GitChanges
```

System scope:

```powershell
$env:ProgramFiles\PowerShell\Modules\Commit-GitChanges
```

Create the folder and move your script:

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Commit-GitChanges" -Force
Move-Item -Path "D:\path\to\your\Commit-GitChanges.psm1" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\Commit-GitChanges\"
Move-Item -Path "D:\path\to\your\emoji-config.json" -Destination "$env:USERPROFILE\Documents\Power
```

---

🔙 [back to 📂 CmdLets](../)
