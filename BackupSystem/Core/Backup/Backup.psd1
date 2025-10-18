@{
    RootModule = 'Backup.psm1'
    RequiredModules = @('Deduplication')
    ModuleVersion = '1.0.0' 
    Author = 'Sebastian Cichoński'
    Description = 'Moduł do tworzenia kopii zapasowych' 
    FunctionToExport = @(
        'Initialize-BackupEnvironment',
        'Get-SourceFiles',
        'Load-BackupSettings',
        'Process-File',
        'Backup-File'
    )
}