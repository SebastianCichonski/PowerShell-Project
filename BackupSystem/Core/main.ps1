# importowanie modułu Deduplication i modułu Backup
Import-module ".\Deduplication\Deduplication.psm1"
Import-module ".\Backup\Backup.psm1"

# initializacja środowiska backupu
Initialize-BackupEnvironment 

# załadowanie ustawień backupu
$backupSettings = Load-BackupSettings -settingsFilePath ".\..\Config\settings.json"

# pobranie listy plików źródłowych do backupu
$sourceFiles = Get-SourceFiles -sourceFolders $backupSettings

# załadowanie indeksu deduplikacji
$dedupIndex = Load-DedupIndex -dedupIndexPath $backupSettings.DedupIndexPath


# przetworzenie każdego pliku źródłowego ($dedupIndex jest przekazywany przez referencję)
Process-File -sourceFiles $sourceFiles -dedupIndex ([ref]$dedupIndex) -backupRoot $backupSettings.BackupRoot

# zapisanie zaktualizowanego indeksu deduplikacji
Save-DedupIndex -dedupIndex $dedupIndex -dedupIndexPath $backupSettings.DedupIndexPath

    

