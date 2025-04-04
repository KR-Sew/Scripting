param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [int]$MemoryMB
)

# Function to display colored messages
function Write-Message {
    param (
        [string]$Message,
        [ValidateSet("Info", "Error", "Success")]
        [string]$MessageType = "Info"
    )

    switch ($MessageType) {
        "Info"    { Write-Host "[INFO]    $Message" -ForegroundColor Cyan }
        "Error"   { Write-Host "[ERROR]   $Message" -ForegroundColor Red }
        "Success" { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
    }
}

# Check if VM exists
$vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if (-not $vm) {
    Write-Message "VM '$VMName' not found." "Error"
    exit 1
}

# Check current memory configuration
$vmMemory = Get-VMMemory -VMName $VMName

# Update memory settings based on dynamic memory status
if ($vmMemory.DynamicMemoryEnabled) {
    Write-Message "Dynamic memory is enabled for VM '$VMName'. Updating memory settings..."

    $startupBytes = $MemoryMB * 1MB
    $minBytes     = $MemoryMB * 1MB
    $maxBytes     = $MemoryMB * 2MB

    Set-VMMemory -VMName $VMName `
        -StartupBytes $startupBytes `
        -MinimumBytes $minBytes `
        -MaximumBytes $maxBytes

    Write-Message "Startup/Minimum: $MemoryMB MB, Maximum: $($MemoryMB * 2) MB" "Success"
} else {
    Write-Message "Static memory is enabled for VM '$VMName'. Updating startup memory..."

    $startupBytes = $MemoryMB * 1MB

    Set-VMMemory -VMName $VMName -StartupBytes $startupBytes

    Write-Message "Startup memory set to $MemoryMB MB." "Success"
}
