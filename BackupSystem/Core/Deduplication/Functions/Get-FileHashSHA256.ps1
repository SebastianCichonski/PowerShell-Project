# Funkcja obliczająca hash SHA256 pliku

function Get-FileHashSHA256 {
        param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [ValidateScript( { Test-Path -Path $_ } )]
            [string] $filePath)
        
        return (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
    }