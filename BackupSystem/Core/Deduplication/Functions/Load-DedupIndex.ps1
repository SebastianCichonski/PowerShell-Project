# Funcja ładuje indeks deduplikacji z pliku JSON

function Load-DedupIndex {
    param (
            [Parameter(Mandatory)]
            [ValidateScript( { Test-Path -Path $_ } )]
            [ValidateNotNullOrEmpty()]
            [string] $dedupIndexPath
        )

    $dedupIndex = Get-Content -Path $dedupIndexPath -Raw | ConvertFrom-Json
        
    # Jeśli plik nie jest zainicjalizowany, dodaj właściwość Files
    if (-not $dedupIndex.Files) {
        $dedupIndex | Add-Member -MemberType NoteProperty -Name "Files" -Value @()
    }
    return $dedupIndex        
}       