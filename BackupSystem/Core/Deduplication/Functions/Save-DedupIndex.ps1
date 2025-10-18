# Funkcja zapisująca indeks deduplikacji do pliku JSON

function Save-DedupIndex {
    param (
        [object] $dedupIndex,
        [string] $dedupIndexPath
    )

    $dedupIndex | ConvertTo-Json -Depth 10 | Set-Content -Path $dedupIndexPath -Encoding UTF8
}
