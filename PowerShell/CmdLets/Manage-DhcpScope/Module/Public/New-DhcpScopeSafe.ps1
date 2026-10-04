function New-DhcpScopeSafe {
    <#
    .SYNOPSIS
    Safely creates an IPv4 DHCP scope and optionally configures common scope options.

    .DESCRIPTION
    Creates a DHCPv4 scope only when it does not already exist. Validates IPv4 input,
    verifies that ScopeId matches StartRange/SubnetMask, supports remote DHCP servers,
    and implements native -WhatIf/-Confirm behavior.

    .EXAMPLE
    New-DhcpScopeSafe -Name 'Servers VLAN 205' -ScopeId 10.10.205.0 `
        -StartRange 10.10.205.10 -EndRange 10.10.205.240 `
        -SubnetMask 255.255.255.0 -Router 10.10.205.254 `
        -DnsServers 10.0.0.10,10.0.0.11 -DomainName 'vezu.ru' -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$StartRange,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$EndRange,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$SubnetMask,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$ScopeId,
        [string]$Router,
        [string[]]$DnsServers,
        [string]$DomainName,
        [string]$ComputerName = $env:COMPUTERNAME,
        [ValidateSet('Active','Inactive')][string]$State = 'Active',
        [TimeSpan]$LeaseDuration
    )

    Test-DhcpAdminPrerequisite

    $addresses = @($StartRange, $EndRange, $SubnetMask, $ScopeId)
    if ($Router) { $addresses += $Router }
    if ($DnsServers) { $addresses += $DnsServers }
    foreach ($address in $addresses) {
        if (-not (Test-IPv4Address $address)) { throw "Invalid IPv4 address: $address" }
    }

    if ((ConvertTo-IPv4UInt32 $StartRange) -gt (ConvertTo-IPv4UInt32 $EndRange)) {
        throw "StartRange ($StartRange) must not be greater than EndRange ($EndRange)."
    }

    $calculatedScope = Get-IPv4NetworkAddress -Address $StartRange -SubnetMask $SubnetMask
    if ($calculatedScope -ne $ScopeId) {
        throw "ScopeId '$ScopeId' does not match the network '$calculatedScope' calculated from StartRange '$StartRange' and SubnetMask '$SubnetMask'."
    }

    $existing = Get-DhcpServerv4Scope -ComputerName $ComputerName -ScopeId $ScopeId -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Warning "DHCP scope $ScopeId already exists on $ComputerName. No changes were made."
        return $existing
    }

    $target = "$ComputerName / $ScopeId ($Name)"
    if (-not $PSCmdlet.ShouldProcess($target, 'Create DHCPv4 scope')) { return }

    $params = @{
        ComputerName = $ComputerName
        Name         = $Name
        StartRange   = $StartRange
        EndRange     = $EndRange
        SubnetMask   = $SubnetMask
        State        = $State
        ErrorAction  = 'Stop'
    }
    if ($PSBoundParameters.ContainsKey('LeaseDuration')) { $params.LeaseDuration = $LeaseDuration }

    try {
        Add-DhcpServerv4Scope @params
        Write-Verbose "Created DHCP scope $ScopeId on $ComputerName."

        $optionParams = @{ ComputerName=$ComputerName; ScopeId=$ScopeId; ErrorAction='Stop' }
        if ($Router)     { $optionParams.Router = $Router }
        if ($DnsServers) { $optionParams.DnsServer = $DnsServers }
        if ($DomainName) { $optionParams.DnsDomain = $DomainName }

        if ($optionParams.ContainsKey('Router') -or $optionParams.ContainsKey('DnsServer') -or $optionParams.ContainsKey('DnsDomain')) {
            Set-DhcpServerv4OptionValue @optionParams
            Write-Verbose "Configured scope options for $ScopeId."
        }

        Get-DhcpServerv4Scope -ComputerName $ComputerName -ScopeId $ScopeId -ErrorAction Stop
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
