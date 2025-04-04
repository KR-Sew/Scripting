param (
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [Parameter(Mandatory=$true)]
    [int]$MemoryMB
)

# Check if VM exists
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Error "VM '$VMName' not found."
    exit 1
}

# Check current memory config
$vmMemory = Get-VMMemory -VMName $VMName

# If Dynamic Memory is enabled, update minimum, startup, and maximum
if ($vmMemory.DynamicMemoryEnabled) {
    Write-Output "Dynamic memory is enabled for VM '$VMName'. Updating memory settings..."
    
    Set-VMMemory -VMName $VMName `
        -StartupBytes (${MemoryMB}MB) `
        -MinimumBytes (${MemoryMB}MB) `
        -MaximumBytes (${MemoryMB * 2}MB)

    Write-Output "Memory updated to ${MemoryMB}MB startup/minimum and ${MemoryMB * 2}MB maximum."
}
else {
    Write-Output "Static memory is enabled for VM '$VMName'. Updating startup memory..."
    
    Set-VMMemory -VMName $VMName -StartupBytes (${MemoryMB}MB)

    Write-Output "Memory updated to ${MemoryMB}MB."
}
