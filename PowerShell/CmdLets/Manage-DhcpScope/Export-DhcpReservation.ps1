function Export-DhcpReservation {
    param(
        [Parameter(Mandatory)]
        [string[]]$ScopeId,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $BLUE = "Cyan"

    function Write-Log {
        param([string]$Message, [string]$Level = "INFO")
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$ts][$Level] $Message" -ForegroundColor $BLUE
    }

    Write-Log "Starting export of DHCP reservations..."

    $all = @()

    foreach ($scope in $ScopeId) {
        try {
            Write-Log "Reading scope $scope"

            $res = Get-DhcpServerv4Reservation -ScopeId $scope -ErrorAction Stop

            foreach ($r in $res) {
                $all += [PSCustomObject]@{
                    ScopeId    = $scope
                    IPAddress  = $r.IPAddress
                    ClientId   = $r.ClientId
                    Name       = $r.Name
                    Description= $r.Description
                    Type       = $r.Type
                }
            }

            Write-Log "Collected $($res.Count) reservations from $scope" "OK"
        }
        catch {
            Write-Log "Failed to read scope $scope : $_" "ERROR"
        }
    }

    $all | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8

    Write-Log "Export completed → $Path" "OK"
}