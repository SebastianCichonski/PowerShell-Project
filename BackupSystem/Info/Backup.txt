
###########Backup System Core Module#########

function Load-BackupSettings {
    param([string] $settingsFilePath = "..\Config\settings.json")

    if(-not (Test-Path -Path $settingsFilePath)) {
        throw "Settings file not exist: $settingsFilePath"
    }
    return Get-Content -Path $settingsFilePath | ConvertFrom-Json
}

function Get-SourceFiles {
    param([Object] $settingsFile)

    $allFiles = @()

    # Pobieranie plików z uwzględnieniem filtrów
    foreach ($sourceFolders in $settingsFile.SourceFolders) {
    $path =  $sourceFolders.path
    $include = $sourceFolders.include
    $exclude = $sourceFolders.exclude  

    if(-not (Test-Path -Path $path)) {
        Write-Error "Source path not exist: $filePath"
        continue
    }
   
    $files = Get-ChildItem -Path $path -Recurse -File
    if($include -and $include.Count -gt 0) {
        $files = $files | Where-Object { $include -contains "*$($_.Extension)" }
    }

    if($exclude -and $exclude.Count -gt 0) { 
        $files = $files | Where-Object { 
            $matchExcluded = $false
            foreach ($ex in $exclude) {
                if ($_.FullName -like "*\$ex\*") {
                    $matchExcluded = $true
                }
            }
            return -not $matchExcluded
        }
    }
    
    # Tworzenie obiektów z informacjami o plikach
    foreach($file in $files) {
        $allFiles += [PSCustomObject]@{
            SourcePath = $file.FullName
            Name = $file.Name
            Extension = $file.Extension
            Size = $file.Length
            LastModified = $file.LastWriteTime
        }
    }
    }
    return $allFiles
}

function Initialize-BackupEnvironment {
    param ([object] $settingsFile)

    $backupRoot = $settingsFile.BackupRoot
    $sourceFolders = $settingsFile.SourceFolders
    $logPath = Join-Path -Path $backupRoot -ChildPath "Logs"
    
    if( -not (Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    }

    # Tworzenie struktury folderów backupu
    foreach($folder in $sourceFolders) {
       $targetSubFolder = Split-Path -Path $folder.path -Leaf
       $fullTargetPath = Join-Path -Path $backupRoot -ChildPath $targetSubFolder
       $dedupPath = Join-Path -Path $fullTargetPath -ChildPath "Deduplicated"
       $versionPath = Join-Path -Path $fullTargetPath -ChildPath "Versions"
       $metadataPath = Join-Path -Path $fullTargetPath -ChildPath "Metadata"

       # Tworzenie folderów jeśli nie istnieją
       foreach($path in @($dedupPath, $versionPath, $metadataPath)){
        if( -not(Test-Path -Path $path)){
            New-Item -Path $path -ItemType Directory -Force | Out-Null  
        }
       }
       
       # Tworzenie plików metadanych jeśli nie istnieją
       $dedupFile = Join-Path -Path $metadataPath -ChildPath "dedup_index.json"
       $versionFile = Join-Path -Path $metadataPath -ChildPath "version_index.json"

       if(-not(Test-Path $dedupFile)) {
        '{}' | Set-Content -Path $dedupFile -Encoding UTF8
       }
       if(-not(Test-Path $versionFile)) {
        '{ "Files":[]}' | Set-Content -Path $versionFile -Encoding UTF8
       }
       }
    }

    # #########Deduplication Module#########

    function Get-FileHashSHA256 {
        param([string] $filePath)
        
        if(-not (Test-Path $filePath)) {
            throw "File not exist: $filePath"
        }
        return (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
    }

    function Load-DedupIndex {
        param ([string] $dedupIndexPath)

        if(-not(Test-Path $dedupIndexPath)) {
            throw "File 'dedup_index.json' not exist."
        }

        $dedupIndex = Get-Content -Path $dedupIndexPath -Raw | ConvertFrom-Json
        
        # Jeśli plik nie jest zainicjalizowany, dodaj właściwość Files
        if(-not $dedupIndex.Files) {
            $dedupIndex | Add-Member -MemberType NoteProperty -Name "Files" -Value @()
        }
        return $dedupIndex        
    }

    function Save-DedupIndex {
        param (
            [object] $dedupIndex,
            [string] $dedupIndexPath
        )

        $dedupIndex | ConvertTo-Json -Depth 10 | Set-Content -Path $dedupIndexPath -Encoding UTF8
    }

    function Classify-FileStatus {
        param(
            [object] $file, 
            [object] $dedupIndex
        )

        $fileHash = Get-FileHashSHA256 -filePath $file.FullName
        $filePath = $file.FullName
        $knownHashes = @()
        $knownPaths = @()

        $knownHashes = $dedupIndex.Files | ForEach-Object { $_.Hash }
        $knownPaths = $dedupIndex.Files | ForEach-Object { $_.OriginalPath }

        if($knownHashes.Count -gt 0) {
            if(-not ($knownPaths -contains $filepath)) {
                if($knownHashes -contains $fileHash) {
                    return "Duplicate"
                } else {
                    return "New"
                }
            } 
            else {
                if($knownHashes -contains $fileHash) {
                    return "Unchanged"
                } 
                else {
                    return "Modified"
                }
            }
        } 
        else {
            return "New"
        }
    }

    function Process-File {
        param(
            [object] $sourceFiles, 
            [object] $dedupIndex, 
            [string] $backupRoot
        )
        foreach($file in $sourceFiles) {
            $status = Classify-FileStatus -file $file -dedupIndex $dedupIndex
            $hashFile = Get-FileHashSHA256 -filePath $file.SourcePath

            # Budowanie ścieżki docelowej
            $pathParts = $file.SourcePath.Split("\")
            $secondPart = $pathParts[1] 
            $extension = $file.Extension.TrimStart(".")
            $destinationPath = Join-Path -Path $backupRoot -ChildPath "$secondPart\Deduplicated\$hashFile.$extension"

            switch($status) {
                "New" {
                    Backup-File -path $file.SourcePath -destination 
                    Update-DedupIndex
                }
                "Modified" {
                    Backup-File
                    Update-DedupIndex
                }
                "Duplicate" {
                    Update-DedupIndex
                }
                "Unchanged" {
                    # Loguj brak zmian
                }
            }
        }
    }



    $dedup = Load-DedupIndex -dedupIndexPath "D:\BackupFolder\Share1\Metadata\dedup_index.json" 
    $dedup.Files

Get-FileHashSHA256 -filePath "D:\backupFolder\Share1\metadata\dedup_index.json"
$settings = Load-BackupSettings 
Initialize-BackupEnvironment -settingsFile $settings
$sourceFiles = Get-SourceFiles -settingsFile $settings

