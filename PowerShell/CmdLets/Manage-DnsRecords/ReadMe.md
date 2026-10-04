# <img src="../../../Assets/Powershell.svg" width="35" alt="PowerShell"> Manage DNS zone CmdLets  

[![PowerShell](https://custom-icon-badges.demolab.com/badge/.-Microsoft-blue.svg?style=flat&logo=powershell-core-eyecatch32&logoColor=white)](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://docs.microsoft.com/en-us/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

PowerShell Custom cmdlets for managing **DNS** zones such as `Export` and `Import` **dns** zones

## 📂 Description  

- 📄 [**`Export-DnsZone.p1`**](./Export-DnsZone.ps1)
- 📄 [**`Get-SpecDNSRec.ps1`**](./Get-SpecDNSRec.ps1)
- 📄 [**`Import-DnsZone.ps1`**](./Import-DnsZone.ps1)
- 📄 [**`Move-DnsRecords`**](./Move-DnsRecords.ps1)
- 📄 [**`Replace-DNSDomain`**](Replace-DNSDomain.ps1)
  - tiny helper to replace a domain name in an exported *.csv file before import it
  - Run the script like this:

    ```powershell
     .\Replace-DnsDomain.ps1 `
            -File .\u-booking.ru.csv `
            -OldDomain "u-booking.ru" `
            -NewDomain "manyhands.pro"
    ```

- 📂 [**`Module`**](./Module/)
- 📄 [README.md](ReadMe.md)

---

🔙 [back to 📂 Powershell](../)
