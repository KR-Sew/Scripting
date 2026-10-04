Import-Module DhcpAdminTools -Force

# Export reservations from selected scopes.
Export-DhcpReservation `
    -ComputerName 'V08' `
    -ScopeId '10.10.204.0','10.10.205.0' `
    -Path '.\reservations.csv' `
    -Verbose

# Preview restoring rows to their original ScopeId values.
Import-DhcpReservation `
    -ComputerName 'V08' `
    -Path '.\reservations.csv' `
    -WhatIf

# Or redirect every imported reservation to one destination scope:
# Import-DhcpReservation -ComputerName 'V08' -Path '.\reservations.csv' `
#     -DestinationScope '10.10.205.0' -WhatIf
