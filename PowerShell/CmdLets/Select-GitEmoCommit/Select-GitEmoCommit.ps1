function Select-GitEmoCommit {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Files")]
        [ArgumentCompleter({ param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Get-ChildItem -Path . -File | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object { $_.Name }
        })]
        [string[]]$Path,  # Enables tab-completion for file selection

        [ValidateSet("feat", "fix", "docs", "style", "refactor", "perf", "test", "chore", "ci")]
        [string]$CommitType, # Commit type

        [string]$Message, # Commit message

        [switch]$Push,
        [string]$Branch
    )

    # Step 1: File Selection
    if (-not $Path) {
        Write-Host "ℹ️  Use [TAB] to select files or type 'all' for everything." -ForegroundColor Cyan
        $Path = Read-Host "Enter file(s) to add (comma-separated or 'all')"

        if ($Path -eq "all") {
            git add .
        } else {
            $Path = $Path -split "," | ForEach-Object { $_.Trim() }
            git add $Path
        }
    } else {
        git add $Path
    }

    Write-Host "✅ Files added to commit:" -ForegroundColor Green
    $Path | ForEach-Object { Write-Host "  - $_" }

    # Step 2: Commit Type Selection
    if (-not $CommitType) {
        Write-Host "`n🔹 Available Commit Types:" -ForegroundColor Cyan
        Write-Host "  - feat, fix, docs, style, refactor, perf, test, chore, ci"

        do {
            $CommitType = Read-Host "Enter commit type"
        } until ($CommitType -in @("feat", "fix", "docs", "style", "refactor", "perf", "test", "chore", "ci"))
    }

    # Step 3: Commit Message
    if (-not $Message) {
        $Message = Read-Host "Enter commit message"
    }

    # Emoji mapping
    $commitEmojis = @{
        "feat" = "✨"; "fix" = "🐛"; "docs" = "📝"; "style" = "🎨"; 
        "refactor" = "♻️"; "perf" = "⚡"; "test" = "✅"; "chore" = "🔧"; "ci" = "🚀"
    }

    # Create commit message
    $finalMessage = "$($commitEmojis[$CommitType]) [$CommitType] $Message"
    git commit -m "$finalMessage"

    Write-Host "✅ Commit added: $finalMessage" -ForegroundColor Green

    # Step 4: Handle Git Push
    if ($Push) {
        if (-not $Branch) {
            $Branch = Read-Host "Enter branch to push to"
        }
        git push origin $Branch
        Write-Host "🚀 Pushed to $Branch" -ForegroundColor Green
    }
}
