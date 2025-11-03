# BackupSystem — system backupu z deduplikacją i wersjonowaniem

Ten dokument opisuje projekt prostego systemu backupu z modułem deduplikacji oraz miejscem na przyszłe rozszerzenie o wersjonowanie.

## 1. Cel projektu
Celem projektu jest dostarczenie lekkiego, modularnego, skryptowalnego systemu tworzenia kopii zapasowych plików z następującymi cechami:

- automatycznie wykrywa zmiany w plikach,
- unika kopiowania duplikatów (deduplikacja na podstawie SHA256) i przechowywuje jeden egzemplarz,
- przechowywuje kilka ostatnich wersji backupowanych plików (wersjonowanie — w fazie projektowania),
- loguje wykonane akcje do pliku logu
- umożliwia łatwe testowanie i rozbudowę o raportowanie i harmonogramy.

Projekt jest przeznaczony dla użytkowników technicznych, administratorów i pasjonatów automatyzacji, którzy chcą mieć pełną kontrolę nad procesem backupu.

## 2. Założenia projektu
- Backup działa lokalnie, na plikach zdefiniowanego folderu źródłowego.
- Deduplikacja oparta na hashach SHA256.
- Indeks zmian przechowywany w pliku `dedup_index.json`.
- Modularna struktura kodu: każdy komponent w osobnym module.
- Wersjonowanie będzie dodane jako osobny moduł (planowane).
- Logowanie operacji za pomocą oddzielnego modułu
- Projekt gotowy do integracji z GUI lub harmonogramem (np. Task Scheduler).
- Konfiguracja backupu będzie w jednym pliku `settings.json`

## 3. Wymagania
- System uruchamiany jest na Windows PowerShell (skrypty testowane na PowerShell 5.x / Windows PowerShell).
- Administrator uruchamia skrypty z prawami pozwalającymi tworzyć foldery i pliki w lokalizacji backupu.
- Dysk docelowy ma wystarczającą pojemność na składowanie danych (pierwotne i zdeduplikowane metadane + wersje).
- Moduł Pester w wersi 5 do testowania kodu

## 4. Struktura repozytorium projektu
```
BackupSystem/
│
├── Core/
│   ├── Deduplication/
│   │   ├── Deduplication.psm1
│   │   ├── Deduplication.psd1
│   │   └── Functions/
│   │       ├── Classify-FileStatus.ps1
│   │       ├── Update-DedupIndex.ps1
│   │       ├── Load-DedupIndex.ps1
│   │       └── Save-DedupIndex.ps1
│   │
│   ├── Backup/
│   │   ├── Backup.psm1
│   │   ├── Backup.psd1
│   │   └── Functions/
│   │       ├── Backup-File.ps1
│   │       ├── Process-File.ps1
│   │       └── Get-SourceFiles.ps1
│   │
│   ├── Versioning/ 
│   │   ├── Versioning.psm1
│   │   ├── Versioning.psd1
│   │   └── Functions/
│   │       ├── Add-VersionEntry.ps1
│   │       ├── Get-FileHistory.ps1
│   │       └── Compare-Versions.ps1
│   │
│   ├── Logging/
│   │   ├── Logging.psm1
│   │   ├── Logging.psd1
│   │   └── Functions/
│   │       ├── Write-Log.ps1
│   │       ├── Initialize-Log.ps1
│   │       └── Get-LogSummary.ps1
│   │
│   └── Tests/
│       ├── Test-Classify-FileStatus.Tests.ps1
│       ├── Test-Update-DedupIndex.Tests.ps1
│       ├── Test-Process-File.Tests.ps1
│       └── Test-Backup-File.Tests.ps1
│
├── Config/
│   └── settings.json
│
├── Main.ps1
└── README.md

```


## 5. Opis implementacji
Implementacja opiera się na zestawie prostych skryptów PowerShell podzielonych na moduły.

### 5.1 Budowa modułu
Tworząc moduł wybrano utrzymywanie poszczególnych funkcji modułu nie w pliku `.pms1` a w odrębnych plikach `.ps1` zgrupowanych w folderze `\Functions`. Plik `pms1` ładuje wszystkie funkcje do modułu:
```powershell
Get-ChildItem -Path "$PSScriptRoot\Functions\*.ps1" | ForEach-Object {
    . $_.FullName
}
```
Co daje takie rozwiązanie?:
- czytelność - każda funkcja jest w odrębnym pliku
- testowalność - łatwe testy jednostkowe
- bezpieczeństwo - bezpieczne zmienne lokalne
- skalowalność - gotowe do użycia w innych projektach
- dokumentacja - czytelna w plikach poszczególnych funkcji
  
### 5.2 Opis modułów

#### 🔹 Deduplication
  `Deduplication.psm1` + `Deduplication.psd1` — moduł ładujący funkcje deduplikacji.
- Funkcja `Classify-FileStatus` klasyfikuje pliki jako `New`, `Modified`, `Duplicate`, `Unchanged`.
- Funkcja `Update-DedupIndex` aktualizuje indeks po każdym przetworzonym pliku.
- Funkcja `Load-DedupIndex` wczytuje indeks z pliku JSON lub tworzy nowy.
- Funkcja `Save-DedupIndex` zapisuje aktualny stan indeksu.

#### 🔹 Backup
  `Backup.psm1` + `Backup.psd1` — główny moduł backupu (ładowany przez `Main.ps1`).
- Funkcja `Backup-File` kopiuje plik do folderu backupu z nazwą opartą na hashu.
- Funkcja `Process-File` obsługuje logikę backupu i aktualizacji indeksu.
- Funkcja `Get-SourceFiles` pobiera listę plików do backupu.

#### 🔹Versioning 
#### 🔹 Logging

#### 🔹 Main.ps1
- Plik główny skryptu - ładuje moduły, przetwarza pliki, zapisuje indeks.


## 6. Główne kroki działania
1. `Load-BackupSettings` — wczytanie konfiguracji z `Config/settings.json`.
2. `Initialize-BackupEnvironment` — przygotowanie struktury katalogów (Logs, Metadata, Deduplicated, Versions).
3. `Get-SourceFiles` — zebranie listy plików z określonych ścieżek.
4. `Classify-FileStatus` + `Get-FileHashSHA256` — klasyfikacja plików względem indeksu deduplikacji: New, Duplicate, Unchanged, Modified.
5. `Process-File` / `Backup-Files` — wykonanie kopii fizycznej pliku (lub odnotowanie duplikatu) oraz aktualizacja indeksu deduplikacji.


## 7. Opis testów
  Projekt zawiera następujące rodzaje testów Pester (v5) w katalogu `Tests`:
  - Testy jednostkowe dla każdej funkcji `.ps1` (np. `Classify-FileStatus`, `Update-DedupIndex`)
  - Testy integracyjne: uruchomienie `Main.ps1` na folderze testowym
  - Testy scenariuszowe:
    - dodanie nowego pliku,
    - modyfikacja istniejącego,
    - utworzenie kopii pliku przed backupem (sprawdzenie deduplikacji),
    - brak zmian (sprawdzenie pominięcia).

Testy krytycznych funkcji:
  - `Deduplication.Classify-FileStatus.Tests.ps1` — testy jednostkowe klasyfikacji statusu plików (New, Duplicate, Unchanged, Modified). Testy używają izolacji (mockowanie lub dot-sourcing zależności) tak, aby nie polegać na rzeczywistych plikach.
  - `Deduplication.Get-FileHashSHA256.Tests.ps1` — testy funkcji haszującej plik.

## 8. Możliwości rozbudowy
-  Eksport historii do CSV / JSON
-  GUI do zarządzania backupem i przeglądania wersji
-  Harmonogram backupów (Task Scheduler / cron)
-  Powiadomienia o zmianach (mail, toast, log)
-  Testy automatyczne (Pester)



## 9. Autor

Projekt stworzony przez [Sebastian Cichoński](https://github.com/SebastianCichonski) - [sebqu@outlook.com](mailto.sebqu@outlook.com) - 
10.2025