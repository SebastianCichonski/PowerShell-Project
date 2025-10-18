# Funkcja przetwarzająca pliki do backupu z uwzględnieniem deduplikacji

function Process-File {
    param(
        [object] $sourceFiles, 
        [object] $dedupIndex, 
        [string] $backupRoot
    )
    foreach ($file in $sourceFiles) {
        $status = Classify-FileStatus -file $file -dedupIndex $dedupIndex
        $hashFile = Get-FileHashSHA256 -filePath $file.SourcePath

        # Budowanie ścieżki docelowej
        $pathParts = $file.SourcePath.Split("\")
        $secondPart = $pathParts[1] 
        $extension = $file.Extension.TrimStart(".")
        $destinationPath = Join-Path -Path $backupRoot -ChildPath "$secondPart\Deduplicated\$hashFile.$extension"

        switch ($status) {
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