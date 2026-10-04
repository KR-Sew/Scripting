function Test-DhcpAdminPrerequisite {
    [CmdletBinding()]
    param()

    if (-not (Get-Module -ListAvailable -Name DhcpServer)) {
        throw "The DhcpServer PowerShell module is not installed. Install the DHCP Server management tools (RSAT-DHCP) and try again."
    }

    Import-Module DhcpServer -ErrorAction Stop
}
