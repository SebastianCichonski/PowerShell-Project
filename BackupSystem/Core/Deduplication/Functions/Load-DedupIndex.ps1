# Funcja ładuje indeks deduplikacji z pliku JSON

function Load-DedupIndex {
    param ([string] $dedupIndexPath)

    if (-not(Test-Path $dedupIndexPath)) {
        throw "File 'dedup_index.json' not exist."
    }

    $dedupIndex = Get-Content -Path $dedupIndexPath -Raw | ConvertFrom-Json
        
    # Jeśli plik nie jest zainicjalizowany, dodaj właściwość Files
    if (-not $dedupIndex.Files) {
        $dedupIndex | Add-Member -MemberType NoteProperty -Name "Files" -Value @()
    }
    return $dedupIndex        
}