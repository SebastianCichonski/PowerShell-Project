@{
    RootModule = 'Deduplication.psm1'
    ModuleVersion = '1.0.0' 
    Author = 'Sebastian Cichoński'
    Description = 'Moduł do wykrywania duplikatów plików' 
    FunctionToExport = @(
        'Get-FileHashSHA256',
        'Load-DedupIndex',
        'Save-DedupIndex',
        'Update-DedupIndex',
        'Classify-FileStatus'
    )
}