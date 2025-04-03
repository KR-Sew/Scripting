#  Requirements

# ✅ The VM must be running.
# ✅ PowerShell Direct works only on Hyper-V host (not remote VMs).
# ✅ The VM must be Windows with PowerShell enabled.
# How to use the script:
# .\Set-VMNetwork.ps1 -VMName "MyVM" -AdapterName "Ethernet" -IPAddress "192.168.1.100" -SubnetMask "24" -Gateway "192.168.1.1" -DNSServers "8.8.8.8", "8.8.4.4"


param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,          # Name of the VM
    
    [Parameter(Mandatory = $false)]
    [string]$AdapterName,     # (Optional) Name of the network adapter inside the VM
    
    [Parameter(Mandatory = $true)]
    [string]$IPAddress,       # Static IP address to assign
    
    [Parameter(Mandatory = $true)]
    [string]$SubnetMask,      # Subnet mask
    
    [Parameter(Mandatory = $true)]
    [string]$Gateway,         # Default gateway
    
    [Parameter(Mandatory = $true)]
    [string[]]$DNSServers     # DNS servers (array)
)

# Check if the VM exists and is running
$VM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $VM) {
    Write-Host "❌ Error: VM '$VMName' does not exist!" -ForegroundColor Red
    exit 1
}
if ($VM.State -ne 'Running') {
    Write-Host "❌ Error: VM '$VMName' is not running!" -ForegroundColor Red
    exit 1
}

# Auto-detect VM network adapter if not provided
if (-not $AdapterName) {
    Write-Host "🔍 No adapter specified. Detecting VM NIC..."
    
    # Get the first connected VM network adapter
    $VMAdapter = Get-VMNetworkAdapter -VMName $VMName | Select-Object -First 1
    if (-not $VMAdapter) {
        Write-Host "❌ Error: No network adapters found for VM '$VMName'!" -ForegroundColor Red
        exit 1
    }

    $VMAdapterMAC = $VMAdapter.MacAddress -replace '-', ':'
    Write-Host "✅ Found VM network adapter: $($VMAdapter.Name) (MAC: $VMAdapterMAC)"

    # Use PowerShell Direct to find the corresponding adapter inside the VM
    $AdapterName = Invoke-Command -VMName $VMName -ScriptBlock {
        param ($VMAdapterMAC)
        
        # List all network adapters inside the VM
        $AllAdapters = Get-NetAdapter | Select-Object Name, MacAddress
        Write-Host "🔍 Inside VM: Available Adapters:"
        $AllAdapters | ForEach-Object { Write-Host "    $($_.Name) | MAC: $($_.MacAddress)" }
        
        Write-Host "🔍 Comparing against external MAC: $VMAdapterMAC"
        
        $MatchingAdapter = $AllAdapters | Where-Object { 
            ($_.MacAddress -replace '-', '').ToLower() -eq $VMAdapterMAC.ToLower()
        } | Select-Object -ExpandProperty Name
   
        
        if (-not $MatchingAdapter) {
            Write-Host "❌ Error: Could not find matching adapter inside the VM!"
            exit 1
        }
        
        Write-Host "✅ Found adapter: $MatchingAdapter"
        return $MatchingAdapter
    } -ArgumentList $VMAdapterMAC

    if (-not $AdapterName) {
        Write-Host "❌ Error: Could not find matching adapter inside the VM!" -ForegroundColor Red
        exit 1
    }

    Write-Host "✅ Matching adapter inside VM: $AdapterName"
}

# Run network configuration inside the VM
Invoke-Command -VMName $VMName -ScriptBlock {
    param ($AdapterName, $IPAddress, $SubnetMask, $Gateway, $DNSServers)

    # Get the network adapter inside the VM
    $Adapter = Get-NetAdapter -Name $AdapterName -ErrorAction SilentlyContinue
    if (-not $Adapter) {
        Write-Host "❌ Error: No network adapter named '$AdapterName' found!" -ForegroundColor Red
        exit 1
    }

    Write-Host "🔍 Configuring network adapter: $AdapterName"

    # Remove existing IP configuration
    Write-Host "⚙️ Removing old IP settings..."
    Remove-NetIPAddress -InterfaceAlias $AdapterName -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $AdapterName -Confirm:$false -ErrorAction SilentlyContinue

    # Set static IP address
    Write-Host "🌐 Assigning IP address: $IPAddress / $SubnetMask"
    New-NetIPAddress -InterfaceAlias $AdapterName -IPAddress $IPAddress -PrefixLength $SubnetMask -DefaultGateway $Gateway

    # Configure DNS servers
    Write-Host "🔧 Setting DNS servers: $($DNSServers -join ', ')"
    Set-DnsClientServerAddress -InterfaceAlias $AdapterName -ServerAddresses $DNSServers

    Write-Host "✅ Network configuration applied successfully!"
} -ArgumentList $AdapterName, $IPAddress, $SubnetMask, $Gateway, $DNSServers

Write-Host "🎉 Network settings configured for VM '$VMName'!" -ForegroundColor Green
