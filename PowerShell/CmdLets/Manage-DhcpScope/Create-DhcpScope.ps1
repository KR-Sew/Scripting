function New-DhcpScopeSafe {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$StartRange,

        [Parameter(Mandatory)]
        [string]$EndRange,

        [Parameter(Mandatory)]
        [string]$SubnetMask,

        [Parameter(Mandatory)]
        [string]$ScopeId,

        [string]$Router,

        [string[]]$DnsServers,

        [string]$DomainName,

        [switch]$WhatIf
    )

    $BLUE = "Cyan"

    function Write-Log {
        param([string]$Message, [string]$Level = "INFO")
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$ts][$Level] $Message" -ForegroundColor $BLUE
    }

    Write-Log "Creating DHCP scope $Name ($ScopeId)"

    # Check if exists
    try {
        Get-DhcpServerv4Scope -ScopeId $ScopeId -ErrorAction Stop | Out-Null
        Write-Log "Scope already exists: $ScopeId" "WARN"
        return
    }
    catch {}

    if ($WhatIf) {
        Write-Log "[WhatIf] Create scope $ScopeId"
        return
    }

    try {
        Add-DhcpServerv4Scope `
            -Name $Name `
            -StartRange $StartRange `
            -EndRange $EndRange `
            -SubnetMask $SubnetMask `
            -State Active `
            -ErrorAction Stop

        Write-Log "Scope created" "OK"
    }
    catch {
        Write-Log "Failed to create scope: $_" "ERROR"
        return
    }

    # Options
    try {
        if ($Router) {
            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -Router $Router
            Write-Log "Router set → $Router"
        }

        if ($DnsServers) {
            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -DnsServer $DnsServers
            Write-Log "DNS set → $($DnsServers -join ', ')"
        }

        if ($DomainName) {
            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -DnsDomain $DomainName
            Write-Log "Domain set → $DomainName"
        }
    }
    catch {
        Write-Log "Failed to set options: $_" "ERROR"
    }

    Write-Log "Scope configuration completed"
}