# Get physical adapter details
$PhysicalAdapters = Get-NetAdapter | Select-Object Name, InterfaceDescription, MacAddress, Status, LinkSpeed

# Get IP Configuration
$IPConfig = Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceIndex, IPv4Address, IPv6Address, DNSServer, DefaultGateway

# Get Network Bridge Info
$BridgeInfo = Get-NetAdapterBinding -ComponentID Team00 | Select-Object Name, Enabled

# Output results
Write-Output "Physical Network Adapter Information:"
$PhysicalAdapters | Format-Table -AutoSize

Write-Output "`nIP Configuration:"
$IPConfig | Format-Table -AutoSize

Write-Output "`nNetwork Bridge Information:"
$BridgeInfo | Format-Table -AutoSize
