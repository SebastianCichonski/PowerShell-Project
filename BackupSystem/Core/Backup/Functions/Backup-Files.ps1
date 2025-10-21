# Funkcja do tworzenia kopii plików z jednego miejsca do drugiego.

function Backup-Files {
    param(
        [Parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ } )]
        [String] $sourcePath,

        [Parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()]
        [String]$destinationPath
    )

    if(Test-Path -Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
    }
}