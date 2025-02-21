function Commit-GitChanges {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("Files")]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            Get-ChildItem -Path . -File | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object { $_.Name }
        })]
        [string[]]$Path,  # Enables tab-completion for file selection

        [ValidateSet("feat", "fix", "docs", "style", "refactor", "perf", "test", "chore", "ci")]
        [string]$CommitType,  # Commit type selection

        [string]$Message  # Commit message
    )

    # Step 1: Select Files (Interactive Mode)
    if (-not $Path) {
        Write-Host "ℹ️  Use `-Path` with [TAB] for autocompletion, or manually enter files." -ForegroundColor Cyan
        Write-Host "   Example: `Commit-GitChanges -Path file1.ps1, file2.ps1`" -ForegroundColor Yellow
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

    # Step 2: Select Commit Type
    if (-not $CommitType) {
        Write-Host "`n🔹 Available Commit Types:" -ForegroundColor Cyan
        Write-Host "  - feat, fix, docs, style, refactor, perf, test, chore, ci"

        do {
            $CommitType = Read-Host "Enter commit type"
        } until ($CommitType -in @("feat", "fix", "docs", "style", "refactor", "perf", "test", "chore", "ci"))
    }

    # Step 3: Enter Commit Message
    if (-not $Message) {
        $Message = Read-Host "Enter commit message"
    }

    # Emoji mapping for commit types
    $commitEmojis = @{
        "feat" = "✨"; "fix" = "🐛"; "docs" = "📝"; "style" = "🎨"; 
        "refactor" = "♻️"; "perf" = "⚡"; "test" = "✅"; "chore" = "🔧"; "ci" = "🚀"
    }

    # Create commit message
    $finalMessage = "$($commitEmojis[$CommitType]) [$CommitType] $Message"
    git commit -m "$finalMessage"

    Write-Host "✅ Commit added: $finalMessage" -ForegroundColor Green
}
