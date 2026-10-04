@{
    RootModule        = 'DnsZoneTools.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '8e87463c-9db1-4e7e-b799-d6fef94ab3c7'
    Author            = 'Andrew'
    Description       = 'Windows DNS zone CSV export, conversion, safe zone creation, and import helpers.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Export-DnsZoneCsv','Import-DnsZoneCsv','Convert-DnsZoneCsv','New-DnsZoneSafe')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData = @{ PSData = @{ Tags = @('DNS','WindowsServer','ActiveDirectory','CSV') } }
}
