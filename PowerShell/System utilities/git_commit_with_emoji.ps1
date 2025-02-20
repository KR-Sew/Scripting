# Define commit message prefixes with emojis
$commitTypes = @{
    "feat"   = "✨";  # New feature
    "fix"    = "🐛";  # Bug fix
    "docs"   = "📝";  # Documentation update
    "style"  = "🎨";  # Code formatting, no logic change
    "refactor" = "♻️"; # Refactoring code
    "perf"   = "⚡";  # Performance improvements
    "test"   = "✅";  # Adding or updating tests
    "chore"  = "🔧";  # Maintenance tasks
    "ci"     = "🚀";  # CI/CD related changes
}

# Prompt user for commit type
$commitType = Read-Host "Enter commit type (feat, fix, docs, style, refactor, perf, test, chore, ci)"

# Validate commit type
if (-not $commitTypes.ContainsKey($commitType)) {
    Write-Host "❌ Invalid commit type. Please use one of the predefined types." -ForegroundColor Red
    exit 1
}

# Prompt for commit message
$commitMessage = Read-Host "Enter commit message"

# Construct final commit message with emoji
$emoji = $commitTypes[$commitType]
$finalMessage = "$emoji [$commitType] $commitMessage"

# Add changes, commit with message, and push
git add .
git commit -m "$finalMessage"
Write-Host "✅ Commit added: $finalMessage" -ForegroundColor Green

# Optional: Uncomment to push automatically
# git push
