# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> PowerShell CmdLet Backup-WSLImage

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![WSL](https://img.shields.io/badge/WSL-Microsoft-blue?style=flat&logo=linux&logoColor=white&logoSize=auto&labelColor=4E9A06)](https://learn.microsoft.com/en-us/windows/wsl/about)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

This cmdlet `Backup-WSLImage` create a WSL backup in a tar archive.

## 📂 Folder contents  

- 📄 [Backup-WSLImage.ps1](./Backup-WSLImage.psm1) # CmdLet module file
- 📄 [About this section](./ReadMe.md) # Project documentation

---

### Here’s the cmdlet `Backup-WSLImage` module with

- ✅ Tab completion for file selection
- ✅ Specify the path to the backup folder

This is a custom PowerShell cmdlet that allows you to back up a WSL distribution to a `.tar` file. This cmdlet will accept parameters for the distribution `name` and the `backup path`.

The cmdlet `Backup-WSLImage` works with parameters

```powershell
Backup-WSLImage -DistroName <> -BackupPath <>
```

Where the parameter is:

- `-DistroName` specify the name of the distribution package for backup
- `-BackupPath` specify the path to the backup folder

To get a list of available distributives in a system you can run the command

```powershell
wsl --list --verbose
```

#### Automatically load cmdlet into any session

To make your `Backup-WSLImage` cmdlet available in every PowerShell session, follow these steps:

1. Save the Module in a Persistent Location

Move your PowerShell script (`Backup-WSLImage.psm1`) to a dedicated module directory. PowerShell expects custom modules in one of these locations:

User scope:

```powershell
$env:USERPROFILE\Documents\PowerShell\Modules\Backup-WSLImage
```

System scope:

```powershell
$env:ProgramFiles\PowerShell\Modules\Backup-WSLImage

Create the folder and move your script:

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Backup-WSLImage" -Force
Move-Item -Path "D:\path\to\your\Backup-WSLImage.psm1" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\Backup-WSLImage\"
```

#### 2. Ensure PowerShell Can Load the Module

Check if PowerShell recognizes your module:

```powershell
$env:PSModulePath -split ';'
```

The module should be in one of the paths listed.

#### 3. Automatically Load the Module in Every Session

Add this line to your PowerShell profile (`$PROFILE`):

```powershell
"Import-Module Backup-WSLImage" | Out-File -Append -Encoding utf8 $PROFILE
```

This ensures that `Backup-WSLImage` is available every time you open PowerShell.

#### 4. Verify

Restart PowerShell and run:

```powershell
Get-Command Backup-WSLImage
```

If it lists your function, everything is set up correctly.

Now, your cmdlet will be available in every session without needing to manually import it. 🚀

---

🔙 [back to 📂 CmdLets](../)
