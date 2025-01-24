# Get motherboard information
$Motherboard = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber, Version

# Output the results
Write-Output "Motherboard Information:"
$Motherboard | Format-Table -AutoSize