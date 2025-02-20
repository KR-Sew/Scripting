function Select-GitFiles {
    [CmdletBinding()]
    param (
        [string]$CommitType,
        [string]$CommitMessage
    )

    # Get changed files
    $changedFiles = git status --porcelain | ForEach-Object { ($_ -split '\s+')[1] }

    if (-not $changedFiles) {
        Write-Host "⚠️ No changes detected. Exiting..." -ForegroundColor Yellow
        return
    }

    # Show changed files and ask user to select
    Write-Host "`n📂 Changed files:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $changedFiles.Count; $i++) {
        Write-Host "$i) $($changedFiles[$i])"
    }

    $selectedIndexes = Read-Host "Enter file numbers to add (comma-separated) or 'all'"

    # Add selected files
    if ($selectedIndexes -eq "all") {
        git add .
    } else {
        $selectedIndexes -split ',' | ForEach-Object { 
            $index = $_.Trim() 
            if ($index -match '^\d+$' -and $index -lt $changedFiles.Count) {
                git add $changedFiles[$index]
            } else {
                Write-Host "❌ Invalid selection: $index" -ForegroundColor Red
            }
        }
    }

    # Commit message with emoji
    $commitTypes = @{
        "feat" = "✨"; "fix" = "🐛"; "docs" = "📝"; "style" = "🎨"; 
        "refactor" = "♻️"; "perf" = "⚡"; "test" = "✅"; "chore" = "🔧"; "ci" = "🚀"
    }

    if (-not $CommitType) {
        $CommitType = Read-Host "Enter commit type (feat, fix, docs, style, refactor, perf, test, chore, ci)"
    }

    if (-not $commitTypes.ContainsKey($CommitType)) {
        Write-Host "❌ Invalid commit type." -ForegroundColor Red
        return
    }

    if (-not $CommitMessage) {
        $CommitMessage = Read-Host "Enter commit message"
    }

    $finalMessage = "$($commitTypes[$CommitType]) [$CommitType] $CommitMessage"

    git commit -m "$finalMessage"
    Write-Host "✅ Commit added: $finalMessage" -ForegroundColor Green
}
