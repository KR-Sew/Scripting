#  Requirements

# ✅ The VM must be running.
# ✅ PowerShell Direct works only on Hyper-V host (not remote VMs).
# ✅ The VM must be Windows with PowerShell enabled.


param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,          # Name of the VM
    
    [Parameter(Mandatory = $true)]
    [string]$AdapterName,     # Name of the network adapter inside the VM
    
    [Parameter(Mandatory = $true)]
    [string]$IPAddress,       # Static IP address to assign
    
    [Parameter(Mandatory = $true)]
    [string]$SubnetMask,      # Subnet mask
    
    [Parameter(Mandatory = $true)]
    [string]$Gateway,         # Default gateway
    
    [Parameter(Mandatory = $true)]
    [string[]]$DNSServers     # DNS servers (array)
)

# Check if the VM is running
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}
if ($VM.State -ne 'Running') {
    Write-Host "❌ Error: VM '$VMName' is not running!" -ForegroundColor Red
    exit 1
}

Write-Host "🔄 Connecting to VM '$VMName' via PowerShell Direct..."

# Run network configuration inside the VM
Invoke-Command -VMName $VMName -ScriptBlock {
    param ($AdapterName, $IPAddress, $SubnetMask, $Gateway, $DNSServers)

    # Get the network adapter
    $Adapter = Get-NetAdapter -Name $AdapterName -ErrorAction SilentlyContinue
    if (-not $Adapter) {
        Write-Host "❌ Error: No network adapter named '$AdapterName' found!" -ForegroundColor Red
        exit 1
    }

    Write-Host "🔍 Found network adapter: $AdapterName"

    # Remove existing IP configuration
    Write-Host "⚙️ Removing existing IP settings..."
    Remove-NetIPAddress -InterfaceAlias $AdapterName -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $AdapterName -Confirm:$false -ErrorAction SilentlyContinue

    # Set static IP address
    Write-Host "🌐 Configuring IP address: $IPAddress / $SubnetMask"
    New-NetIPAddress -InterfaceAlias $AdapterName -IPAddress $IPAddress -PrefixLength $SubnetMask -DefaultGateway $Gateway

    # Configure DNS servers
    Write-Host "🔧 Setting DNS servers: $($DNSServers -join ', ')"
    Set-DnsClientServerAddress -InterfaceAlias $AdapterName -ServerAddresses $DNSServers

    Write-Host "✅ Network configuration applied successfully!"
} -ArgumentList $AdapterName, $IPAddress, $SubnetMask, $Gateway, $DNSServers

Write-Host "🎉 Network settings configured for VM '$VMName'!" -ForegroundColor Green
