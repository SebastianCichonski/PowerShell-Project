# Funkcja do wczytywania ustawień kopii zapasowej z pliku JSON

function Load-BackupSettings {
    param([string] $settingsFilePath = "..\Config\settings.json")

    if(-not (Test-Path -Path $settingsFilePath)) {
        throw "Settings file not exist: $settingsFilePath"
    }
    return Get-Content -Path $settingsFilePath | ConvertFrom-Json
}