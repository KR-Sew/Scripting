param (
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [int]$MemoryMB
)

# Function to display messages
function Write-Message {
    param (
        [string]$Message,
        [string]$MessageType = "Info"
    )
    
    switch ($MessageType) {
        "Info" { Write-Output "[INFO] $Message" }
        "Error" { Write-Error "[ERROR] $Message" }
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
    
    Set-VMMemory -VMName $VMName `
        -StartupBytes ($MemoryMB * 1MB) `
        -MinimumBytes ($MemoryMB * 1MB) `
        -MaximumBytes ($MemoryMB * 2MB)

    Write-Message "Memory updated to $MemoryMB MB startup/minimum and $($MemoryMB * 2) MB maximum."
} else {
    Write-Message "Static memory is enabled for VM '$VMName'. Updating startup memory..."
    
    Set-VMMemory -VMName $VMName -StartupBytes ($MemoryMB * 1MB)

    Write-Message "Memory updated to $MemoryMB MB."
}
