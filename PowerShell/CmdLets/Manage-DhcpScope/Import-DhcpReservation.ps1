function Import-DhcpReservation {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$DestinationScope,

        [switch]$WhatIf
    )


    function Write-Log {
        param([string]$Message, [string]$Level = "INFO")
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$ts][$Level] $Message" -ForegroundColor Cyan
    }

    function Test-Exists {
        param($IP)

        try {
            Get-DhcpServerv4Reservation -ScopeId $DestinationScope -IPAddress $IP -ErrorAction Stop | Out-Null
            return $true
        }
        catch {
            return $false
        }
    }

    Write-Log "Importing reservations from $Path"

    $data = Import-Csv $Path

    foreach ($r in $data) {

        $msg = "Adding $($r.IPAddress) ($($r.Name))"

        if (Test-Exists -IP $r.IPAddress) {
            Write-Log "Skipping existing $($r.IPAddress)" "WARN"
            continue
        }

        if ($WhatIf) {
            Write-Log "[WhatIf] $msg"
            continue
        }

        try {
            Add-DhcpServerv4Reservation `
                -ScopeId $DestinationScope `
                -IPAddress $r.IPAddress `
                -ClientId $r.ClientId `
                -Name $r.Name `
                -Description $r.Description `
                -Type $r.Type `
                -ErrorAction Stop

            Write-Log "$msg" "OK"
        }
        catch {
            Write-Log "Failed $($r.IPAddress) : $_" "ERROR"
        }
    }

    Write-Log "Import completed"
}