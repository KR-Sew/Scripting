Get-NetLbfoTeam | Select-Object Name, TeamingMode, LoadBalancingAlgorithm, Status
Get-NetLbfoTeamMember | Format-Table Name, Team, Status