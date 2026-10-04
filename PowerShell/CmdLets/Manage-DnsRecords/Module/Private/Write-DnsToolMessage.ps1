function Write-DnsToolMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('INFO','OK','WARN','FAIL')][string]$Level,
        [Parameter(Mandatory)][string]$Message
    )
    $label = switch ($Level) { 'INFO' {'[INFO]'} 'OK' {'[ OK ]'} 'WARN' {'[WARN]'} 'FAIL' {'[FAIL]'} }
    $color = switch ($Level) { 'INFO' {'Cyan'} 'OK' {'Green'} 'WARN' {'Yellow'} 'FAIL' {'Red'} }
    Write-Host "$label " -ForegroundColor $color -NoNewline
    Write-Host $Message
}
