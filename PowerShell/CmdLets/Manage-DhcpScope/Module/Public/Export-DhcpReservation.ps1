function Export-DhcpReservation {
    <#
    .SYNOPSIS
    Exports DHCPv4 reservations from one or more scopes to CSV.

    .EXAMPLE
    Export-DhcpReservation -ComputerName V08 -ScopeId 10.10.204.0,10.10.205.0 -Path .\reservations.csv
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Scope')][string[]]$ScopeId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Path,
        [string]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        Test-DhcpAdminPrerequisite
        $items = [System.Collections.Generic.List[object]]::new()
    }
    process {
        foreach ($scope in $ScopeId) {
            if (-not (Test-IPv4Address $scope)) {
                Write-Error "Invalid ScopeId: $scope"
                continue
            }
            try {
                Write-Verbose "Reading reservations from $ComputerName scope $scope."
                $reservations = @(Get-DhcpServerv4Reservation -ComputerName $ComputerName -ScopeId $scope -ErrorAction Stop)
                foreach ($r in $reservations) {
                    $items.Add([pscustomobject][ordered]@{
                        ScopeId     = [string]$scope
                        IPAddress   = [string]$r.IPAddress
                        ClientId    = [string]$r.ClientId
                        Name        = [string]$r.Name
                        Description = [string]$r.Description
                        Type        = [string]$r.Type
                    })
                }
                Write-Verbose "Collected $($reservations.Count) reservation(s) from $scope."
            }
            catch {
                Write-Error -ErrorRecord $_
            }
        }
    }
    end {
        $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        $parent = Split-Path -Parent $fullPath
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null
        }
        $items | Export-Csv -LiteralPath $fullPath -NoTypeInformation -Encoding UTF8 -Force
        Write-Verbose "Exported $($items.Count) reservation(s) to $fullPath."
        Get-Item -LiteralPath $fullPath
    }
}
