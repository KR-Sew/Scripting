# Define the path to the JSON file
$jsonFilePath = "D:\DevRepo\Scripting\Powershell\CmdLets\data.json"

# Load the JSON data
$jsonData = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# Create a custom ArgumentCompleter
function Get-ItemCompleter {
    param (
        [string]$wordToComplete,
        [string]$commandAst,
        [string]$cursorPosition
    )

    # Get the list of items from the JSON data
    $items = $jsonData.items

    # Filter items based on the input
    $filteredItems = $items | Where-Object { $_ -like "$wordToComplete*" }

    # Return the completion results
    return $filteredItems | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, [System.Management.Automation.CompletionResultType]::ParameterValue, $_) }
}

# Register the ArgumentCompleter for a specific command
Register-ArgumentCompleter -CommandName 'Get-Fruit' -ScriptBlock ${function:Get-ItemCompleter}

# Example command to test the completer
function Get-Fruit {
    param (
        [string]$Fruit
    )
    Write-Output "You selected: $Fruit"
}
