function Test-IPv4Address {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Address
    )

    $parsed = $null
    if (-not [System.Net.IPAddress]::TryParse($Address, [ref]$parsed)) { return $false }
    return $parsed.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork
}

function ConvertTo-IPv4UInt32 {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Address)

    if (-not (Test-IPv4Address -Address $Address)) {
        throw "Invalid IPv4 address: $Address"
    }

    $bytes = ([System.Net.IPAddress]::Parse($Address)).GetAddressBytes()
    [Array]::Reverse($bytes)
    return [BitConverter]::ToUInt32($bytes, 0)
}

function Get-IPv4NetworkAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Address,
        [Parameter(Mandatory)][string]$SubnetMask
    )

    $ip = ConvertTo-IPv4UInt32 $Address
    $mask = ConvertTo-IPv4UInt32 $SubnetMask
    $network = $ip -band $mask
    $bytes = [BitConverter]::GetBytes([uint32]$network)
    [Array]::Reverse($bytes)
    return ([System.Net.IPAddress]::new($bytes)).ToString()
}
