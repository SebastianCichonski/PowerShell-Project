# Funkcja inicjalizująca środowisko backupu

function Initialize-BackupEnvironment {
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object] $settingsFile
    )

    $backupRoot = $settingsFile.BackupRoot
    $sourceFolders = $settingsFile.SourceFolders
    $logPath = Join-Path -Path $backupRoot -ChildPath "Logs"
    
    if ( -not (Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    }

    # Tworzenie struktury folderów backupu
    foreach ($folder in $sourceFolders) {
        $targetSubFolder = Split-Path -Path $folder.path -Leaf
        $fullTargetPath = Join-Path -Path $backupRoot -ChildPath $targetSubFolder
        $dedupPath = Join-Path -Path $fullTargetPath -ChildPath "Deduplicated"
        $versionPath = Join-Path -Path $fullTargetPath -ChildPath "Versions"
        $metadataPath = Join-Path -Path $fullTargetPath -ChildPath "Metadata"

        # Tworzenie folderów jeśli nie istnieją
        foreach ($path in @($dedupPath, $versionPath, $metadataPath)) {
            if ( -not(Test-Path -Path $path)) {
                New-Item -Path $path -ItemType Directory -Force | Out-Null  
            }
        }
       
        # Tworzenie plików metadanych jeśli nie istnieją
        $dedupFile = Join-Path -Path $metadataPath -ChildPath "dedup_index.json"
        $versionFile = Join-Path -Path $metadataPath -ChildPath "version_index.json"

        if (-not(Test-Path $dedupFile)) {
            '{}' | Set-Content -Path $dedupFile -Encoding UTF8
        }
        if (-not(Test-Path $versionFile)) {
            '{ "Files":[]}' | Set-Content -Path $versionFile -Encoding UTF8
        }
    }
}