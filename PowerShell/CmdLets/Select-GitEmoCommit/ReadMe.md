# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> PowerShell CmdLet Select-GitEmoCommit

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

This cmdlet works with git and add emoji to the description of the commit.

## 📂 Folder contents  

- 📄 [Select-GitEmoCommit.ps1](Select-GitEmoCommit.ps1) # CmdLet
- 📄 [Emoji-config.json](emoji-config.json) # Collection of commit emoji
- 📄 [Register-ArgumentCompleter](./Register-ArgumentCompleter.ps1) # if the argument completer for `CommitType` is not being triggered correctly apply this fix
- 📄 [About this section](ReadMe.md) # Project documentation

---

### Here’s the cmdlet `Select-GitEmoCommit` module with

- ✅ Tab completion for file selection
- ✅ Emoji-based commit messages
- ✅ Option to add more emojis dynamically
- ✅ Git push with branch selection

It can be add and change emoji in `emoji-config.json` file, you can place the file together with the `cmdlet` file or separately. In any case, has to apply the file for correct operation argument completer (`Register-ArgumentCompleter.ps1`) for correct operation of the tab key.

The cmdlet `Select-GitEmoCommit` works with parameters

```powershell
Select-GitEmoCommit -Path <> -CommitType <> -Message <> -Branch <> -Push
```

Where the parameter is:

- `-Path` the path to the commit file
- `-CommitType` select emoji from `emoji-config.json`
- `-Message` add comments to the commit
- `-Branch`select the branch for the commit. It can be set by default.
- `-Push`the parameter to push the commit

#### Automatically load cmdlet into any session

To make your `Select-GitEmoCommit` cmdlet available in every PowerShell session, follow these steps:

1. Save the Module in a Persistent Location

Move your PowerShell script (`Select-GitEmoCommit.psm1`) and `emoji-config.json` to a dedicated module directory. PowerShell expects custom modules in one of these locations:

User scope:

```powershell
$env:USERPROFILE\Documents\PowerShell\Modules\Select-GitEmoCommit
```

System scope:

```powershell
$env:ProgramFiles\PowerShell\Modules\Select-GitEmoCommit
```

Create the folder and move your script:

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Select-GitEmoCommit" -Force
Move-Item -Path "D:\path\to\your\Select-GitEmoCommit.psm1" -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\Select-GitEmoCommit\"
Move-Item -Path "D:\path\to\your\emoji-config.json" -Destination "$env:USERPROFILE\Documents\Power
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
"Import-Module Select-GitEmoCommit" | Out-File -Append -Encoding utf8 $PROFILE
```

This ensures that `Select-GitEmoCommit` is available every time you open PowerShell.

#### 4. Verify

Restart PowerShell and run:

```powershell
Get-Command Select-GitEmoCommit
```

If it lists your function, everything is set up correctly.

Now, your cmdlet will be available in every session without needing to manually import it. 🚀

---

🔙 [back to 📂 CmdLets](../)
