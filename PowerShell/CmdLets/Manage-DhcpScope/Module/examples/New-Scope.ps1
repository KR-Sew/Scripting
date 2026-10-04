Import-Module DhcpAdminTools -Force

New-DhcpScopeSafe `
    -ComputerName 'V08' `
    -Name 'Servers VLAN 205' `
    -ScopeId '10.10.205.0' `
    -StartRange '10.10.205.10' `
    -EndRange '10.10.205.240' `
    -SubnetMask '255.255.255.0' `
    -Router '10.10.205.254' `
    -DnsServers '10.0.0.10','10.0.0.11' `
    -DomainName 'vezu.ru' `
    -WhatIf
