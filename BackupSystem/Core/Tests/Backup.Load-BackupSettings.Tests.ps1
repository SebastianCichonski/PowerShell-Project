<#
Pester v5 tests for Load-BackupSettings function from Backup.ps1

Strategy:
- Read the original Backup.ps1 and extract only the `function Load-BackupSettings { ... }` block into a temporary file.
- Dot-source the temporary file to define only the tested function (avoids executing the rest of the script).
- Test cases:
  - Loads JSON settings successfully and returns object with expected properties.
  - Throws when the settings file does not exist.
#>

Describe 'Load-BackupSettings' {

    BeforeAll {
        # locate the production script
        $prodScript = Join-Path $PSScriptRoot '..\Backup.ps1'
        $prodScript = (Resolve-Path $prodScript).Path

        # read the script and extract the function definition (simple regex)
        $scriptText = Get-Content -Path $prodScript -Raw
        $match = [regex]::Match($scriptText, '(?s)function\s+Load-BackupSettings\b.*?^\}', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        if(-not $match.Success) {
            throw "Could not extract Load-BackupSettings from $prodScript"
        }

        $tempPath = Join-Path $PSScriptRoot 'temp.LoadBackupSettings.ps1'
        $match.Value | Set-Content -Path $tempPath -Encoding UTF8

        # dot-source only the extracted function
        . $tempPath

        $Script:TempFunctionFile = $tempPath
    }

    AfterAll {
        if(Test-Path -Path $Script:TempFunctionFile) { Remove-Item -Path $Script:TempFunctionFile -Force }
    }

    It 'loads settings from a valid JSON file and returns object' {
        $tempSettings = Join-Path $PSScriptRoot 'tmp-settings.json'
        $json = '{ "BackupRoot": "C:\\BackupRoot", "SourceFolders": [] }'
        $json | Set-Content -Path $tempSettings -Encoding UTF8

        $result = Load-BackupSettings -settingsFilePath $tempSettings

        # Basic assertions
        $result | Should -Not -BeNullOrEmpty
        $result.BackupRoot | Should -Be 'C:\BackupRoot'
        $result.SourceFolders | Should -BeOfType 'System.Object'

        Remove-Item -Path $tempSettings -Force
    }

    It 'throws when settings file does not exist' {
        $missing = Join-Path $PSScriptRoot 'definitely-not-exists.json'

        { Load-BackupSettings -settingsFilePath $missing } | Should -Throw
    }

}
