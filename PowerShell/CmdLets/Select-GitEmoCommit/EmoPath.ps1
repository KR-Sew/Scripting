Register-ArgumentCompleter -CommandName Select-GitEmoCommit -ParameterName CommitType -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $emojiConfigPath = "D:\path\to\your\PowerShell\CmdLets\Select-GitEmoCommit\emoji-config.json" # Update this to the correct absolute path
    if (Test-Path $emojiConfigPath) {
        $emojis = Get-Content -Raw -Path $emojiConfigPath | ConvertFrom-Json
        $emojis.PSObject.Properties.Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
