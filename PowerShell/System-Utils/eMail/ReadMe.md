# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> Add MDaemon address book to MS Office Outlook 2016 - 2021 

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

This folder contains several scripts to setup address book to MS Office Outlook
in Active Directory environment

## 📂 Folder Description

- 📂 [Add MDaemon address book](./Add-AddressBookNoCredentials.ps1)

  `Add-AddressBookNoCredentials.ps1` this script to create LDAP address book entyr for MS Office Outlook 2016-2021

- 📂 [Add MDaemon address book with credentials](./Add-MDaemonAddressBook.ps1)
  
  `Add-MDaemonAddressBook.ps1` this script supports LDAP authentication. If your MDaemon LDAP server requires login you'll need to set `RequireAuth = 1` and provide the username and password fields.
  
- 📂 [Remove address book](./Remove-LDAPAddressBook.ps1)
  
  `Remove-LDAPAddressBook.ps1` this script to safety remove any existing MDaemon LDAP    address book (by DisplayName)
  
✅ Verification

- Open `Outlook → File → Account Settings → Address Books`.
   You should see MDaemon Address Book under LDAP address books.
- Also make sure AD DNS is resolving `mdaemon.domain.local`.

🧪 Optional: Confirm Existing Keys

- You can manually check the path using PowerShell:
  `Get-ChildItem "HKCU:\Software\Microsoft\Office\16.0\Outlook"`

- 📄[README.md](ReadMe.md)                   # Project documentation

---

🔙 [back to 📂 Powershell](../)
