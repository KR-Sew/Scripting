# ================================
# GitFix.psm1
# PowerShell module for cleaning
# and staging file moves in Git.
# ================================

function Remove-GitDeleted {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Verbose "Scanning for deleted tracked files..."

    $deleted = git status --porcelain |
        Where-Object { $_ -match '^\s?D\s+' } |
        ForEach-Object { $_ -replace '^\s?D\s+', '' }

    if (-not $deleted) {
        Write-Host "No deleted tracked files found." -ForegroundColor Green
        return
    }

    Write-Host "`nRemoving deleted files from index:`n" -ForegroundColor Yellow
    $deleted | ForEach-Object { Write-Host "  $_" }

    foreach ($file in $deleted) {
        if ($PSCmdlet.ShouldProcess($file, "git rm --cached")) {
            git rm --cached -- "$file" | Out-Null
        }
    }

    Write-Host "`nDeleted files removed from cache." -ForegroundColor Green
}


function Trace-GitAdded {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Verbose "Scanning for untracked files..."

    $added = git status --porcelain |
        Where-Object { $_ -match '^??\s+' } |
        ForEach-Object { $_ -replace '^\?\?\s+', '' }

    if (-not $added) {
        Write-Host "No new untracked files to stage." -ForegroundColor Green
        return
    }

    Write-Host "`nStaging new files:`n" -ForegroundColor Yellow
    $added | ForEach-Object { Write-Host "  $_" }

    foreach ($file in $added) {
        if ($PSCmdlet.ShouldProcess($file, "git add")) {
            git add -- "$file"
        }
    }

    Write-Host "`nNew files staged." -ForegroundColor Green
}


function Repair-GitMoves {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "`n=== Fixing Git File Moves ===`n" -ForegroundColor Cyan

    Remove-GitDeleted -Verbose:$VerbosePreference
    Stage-GitAdded -Verbose:$VerbosePreference

    Write-Host "`nDone. Run 'git status' to verify." -ForegroundColor Green
}
