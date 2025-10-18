# Backup.psm1

$functionPath = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
Get-ChildItem -Path $functionPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}