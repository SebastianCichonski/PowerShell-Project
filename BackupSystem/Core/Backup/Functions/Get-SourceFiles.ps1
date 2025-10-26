# Funkcja pobierająca pliki źródłowe do backupu na podstawie ustawień

function Get-SourceFiles {
    param([Object] $settingsFile)

    $allFiles = @()

    # Pobieranie plików z uwzględnieniem filtrów
    foreach ($sourceFolders in $settingsFile.SourceFolders) {
        $path = $sourceFolders.path
        $include = $sourceFolders.include
        $exclude = $sourceFolders.exclude  

        if (-not (Test-Path -Path $path)) {
            Write-Error "Source path not exist: $filePath"
            continue
        }
   
        $files = Get-ChildItem -Path $path -Recurse -File
        if ($include -and $include.Count -gt 0) {
            $files = $files | Where-Object { $include -contains "*$($_.Extension)" }
        }

        if ($exclude -and $exclude.Count -gt 0) { 
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
        foreach ($file in $files) {
            $allFiles += [PSCustomObject]@{
                SourcePath   = $file.FullName
                Name         = $file.Name
                Extension    = $file.Extension
                Size         = $file.Length
                LastModified = $file.LastWriteTime
            }
        }
    }
    return $allFiles
}