# <img src="../../Assets/Powershell.svg" width="35" alt="PowerShell"> PowerShell Scripts Collection  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A collection of useful `PowerShell` scripts for **system administration**, **automation**, and **DevOps** workflows on **Windows**.  

## 📂 Folder Description

- 📂 [Manage **Active Directory** users, groups and rights](./Accounts/) in `Accounts` folder

  Folder contains powershell scripts designed for **managing user and group permissions** within the organization. The scripts facilitate the automation of tasks such as creating, modifying, and deleting user accounts and groups, as well as assigning and revoking access rights.

- 📂 [Manage **DNS** service](./DNS/) in `DNS` folder
  
  Contains powershell scripts designed for management **DNS** records and **DNS** service.
   - `Get-SpecDNSRec.ps1`
   - `Move-DNSRecords.ps1`

- 📂 [Manage **Email** messaging system](./eMail/) in `eMail` folder
  
  Contains powershell scripts designed for management messaging system like **MDaemon** and email client applications such as **MS Office Outlook**.

- 📂 [Manage **files** and **folders** and thing like these](./FileSystems/) in `FileSystem` folder
  
  Contains scripts designed for efficient management of files, folders, and the filesystem.

- 📂 [These are small custom **CmdLet's**](./Functions/) in `Functions` folder
  
  Contains custom **CmdLet**:
  - `Install-ZipPackages.ps1` for managing archived files and folders .
  - `Install-ZipPackageAdvance.ps1` the same but with some improvements.
  - `Watch-PrivGroupChanges.ps1`

- 📂 [Managing **Private Keys Infrastructure**](./PKI/) `PKI` folder
  
  Contains scripts designed for management **PKI**.
  - `Export-Cert.ps1` export certificates
  - `Impoert-Cert.ps1` import certificates

- 📂 [Managing **PowerShell** settings](./PoSH/) `PoSH` folder
  
  Contains scripts designed for managing `PowerShell` engine itself:
  - `Update-PowerShell.ps` for updating to the latest version.
  - `Update-PowerShell.txt` the same script but adapted to run just using **Copy&Paste** being in teminal session.
- 📂 [Managing **Print services** settings](./PrintServices/) `PrintServices` folder
  
  Contains powershell scripts designed for management **Print services** and **Print Server** role.

- 📂 [Managing **Remote Desktop Services** settings](./RDServices/) `RDServices` folder
  
  Contains scripts designed for management **Remote Desktop Services** and **Remote Desktop connections**.

- 📂 [Manage System and Serviice scripts](./System-Services/)`System-Servicex` folder

     Contains PowerShell scripts designed for managing system services, retrieving detailed system information, and configuring various system components. The scripts enable users to start, stop, and restart services, gather hardware and software details, and modify system settings to optimize performance and functionality.



- 📄[README.md](ReadMe.md)                   # Project documentation

---

🔙 [back to 📂 Powershell](../)
