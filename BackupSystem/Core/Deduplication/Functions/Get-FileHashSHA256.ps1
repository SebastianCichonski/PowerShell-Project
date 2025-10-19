# Funkcja obliczająca hash SHA256 pliku

function Get-FileHashSHA256 {
        param([string] $filePath)
        
        if(-not (Test-Path $filePath)) {
            throw "File not exist: $filePath"
        }
        return (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
    }