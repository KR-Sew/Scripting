function Select-GitEmoCommit {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Files")]
        [ArgumentCompleter({ param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Get-ChildItem -Path . -File | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object { $_.Name }
        })]
        [string[]]$Path,  # Enables tab-completion for file selection

        [ArgumentCompleter({ param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $emojiConfigPath = "emoji-config.json"
            if (Test-Path $emojiConfigPath) {
                $emojis = Get-Content -Raw -Path $emojiConfigPath | ConvertFrom-Json
                $emojis.PSObject.Properties.Name | Where-Object { $_ -like "$wordToComplete*" }
            }
        })]
        [string]$CommitType, # Commit type

        [string]$Message, # Commit message

        [string]$Branch = "main" , # Default branch to main

        [switch]$Push # Push option
    )

    # Ensure required parameters are provided
    if (-not $Path -or -not $CommitType -or -not $Message) {
        Write-Error "Missing required parameters: -Path, -CommitType, and -Message must be provided."
        return
    }

    # Load emoji configuration from external file
    $emojiConfigPath = "emoji-config.json"
    if (-not (Test-Path $emojiConfigPath)) {
        Write-Error "Emoji configuration file 'emoji-config.json' not found. Please create the file with emoji mappings."
        return
    }

    $commitEmojis = Get-Content -Raw -Path $emojiConfigPath | ConvertFrom-Json
    if (-not $commitEmojis.PSObject.Properties.Name -contains $CommitType) {
        Write-Error "Invalid commit type '$CommitType'. Ensure it's listed in 'emoji-config.json'."
        return
    }

    # Add files to git
    git add $Path

    Write-Host "✅ Files added to commit:" -ForegroundColor Green
    $Path | ForEach-Object { Write-Host "  - $_" }

    # Create commit message
    $finalMessage = "$($commitEmojis.$CommitType) [$CommitType] $Message"
    git commit -m "$finalMessage"

    Write-Host "✅ Commit added: $finalMessage" -ForegroundColor Green

    
    # Switch to the specified branch
    git checkout $Branch
    Write-Host "✅ Switched to branch: $Branch" -ForegroundColor Green

    # Push changes if requested
    if ($Push) {
        if (-not $Branch) {
            $Branch = Read-Host "Enter branch to push to"
        }
        git push origin $Branch
        Write-Host "✅ Changes pushed to remote repository." -ForegroundColor Green
    }
}
