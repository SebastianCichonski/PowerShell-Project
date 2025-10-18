# Funkcja klasyfikująca status pliku w kontekście deduplikacji

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

    if ($knownHashes.Count -gt 0) {
        if (-not ($knownPaths -contains $filepath)) {
            if ($knownHashes -contains $fileHash) {
                return "Duplicate"
            }
            else {
                return "New"
            }
        } 
        else {
            if ($knownHashes -contains $fileHash) {
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