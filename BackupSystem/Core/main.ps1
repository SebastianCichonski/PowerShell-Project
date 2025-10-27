# importowanie modułu Deduplication i modułu Backup
Import-module ".\Deduplication\Deduplication.psm1"
Import-module ".\Backup\Backup.psm1"

# initializacja środowiska backupu
Initialize-BackupEnvironment

# załadowanie ustawień backupu
$backupSettings = Load-BackupSettings -settingsFilePath ".\..\Config\settings.json"

# pobranie listy plików źródłowych do backupu
$sourceFiles = Get-SourceFiles -settingsFile $backupSettings

foreach ($sourceFolder in $backupSettings.SourceFolders) {
    
    $backupRootPath = $backupSettings.BackupRoot
    $sourceFolder = Split-Path -path $sourceFolder.path -Leaf
    $dedupIndexPath = Join-Path -Path $backupRootPath -ChildPath "$sourceFolder\Metadata\dedup_index.json"

# załadowanie indeksu deduplikacji
$dedupIndex = Load-DedupIndex -dedupIndexPath $dedupIndexPath

# przetworzenie każdego pliku źródłowego ($dedupIndex jest przekazywany przez referencję)
Process-File -sourceFiles $sourceFiles -dedupIndex ([ref]$dedupIndex) -backupRoot $backupSettings.BackupRoot

# zapisanie zaktualizowanego indeksu deduplikacji
Save-DedupIndex -dedupIndex $dedupIndex -dedupIndexPath $backupSettings.DedupIndexPath
}
