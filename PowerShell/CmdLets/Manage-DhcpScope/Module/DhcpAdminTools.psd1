@{
    RootModule        = 'DhcpAdminTools.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b7c48d36-0d8f-4af6-a5c7-c9a8dd6b0e13'
    Author            = 'Andrew / OpenAI'
    CompanyName       = ''
    Copyright         = '(c) 2026. All rights reserved.'
    Description       = 'Small PowerShell toolkit for safely creating DHCPv4 scopes and exporting/importing reservations.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('New-DhcpScopeSafe','Export-DhcpReservation','Import-DhcpReservation')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData = @{
        PSData = @{
            Tags = @('DHCP','WindowsServer','Administration','IPv4')
        }
    }
}
