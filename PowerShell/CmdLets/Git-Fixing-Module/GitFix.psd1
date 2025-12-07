@{
    RootModule = 'GitFix.psm1'
    ModuleVersion = '1.0.0'
    GUID = '8f1d8516-2e5b-4484-8c78-e1207e7ab11b'
    Author = 'Andrew'
    Description = 'Utilities for fixing orphaned deletes and moves in Git repositories.'
    FunctionsToExport = @(
        'Remove-GitDeleted',
        'Trace-GitAdded',
        'Repair-GitMoves'
    )
}
