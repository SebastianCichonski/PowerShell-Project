

Describe Get-FileHashSHA256 {
    BeforeAll{
        . "$PSScriptRoot\..\Deduplication\Functions\Get-FileHashSHA256.ps1"
    }

    AfterAll{
        Remove-Item -Path "$PSScriptRoot\TestFolder" -Force -Recurse -ErrorAction SilentlyContinue
    }

    It 'calculates the same hash for identical files' {
        $testFolder = "$PSScriptRoot\TestFolder"
        New-Item -Path $testFolder -ItemType Directory -Force | Out-Null

        $file1Path = Join-Path -Path $testFolder -ChildPath "file1.txt"
        $file2Path = Join-Path -Path $testFolder -ChildPath "file2.txt"

        "This is a test file." | Out-File -FilePath $file1Path -Encoding UTF8
        "This is a test file." | Out-File -FilePath $file2Path -Encoding UTF8

        $hash1 = Get-FileHashSHA256 -filePath $file1Path
        $hash2 = Get-FileHashSHA256 -filePath $file2Path

        $hash1 | Should -Be $hash2
    }

    It 'calculates the same hash for the copy of a file' {
        $testFolder = "$PSScriptRoot\TestFolder"
        New-Item -Path $testFolder -ItemType Directory -Force | Out-Null

        $originalFilePath = Join-Path -Path $testFolder -ChildPath "original.txt"
        $copyFilePath = Join-Path -Path $testFolder -ChildPath "copy.txt"

        "This is a test file." | Out-File -FilePath $originalFilePath -Encoding UTF8
        Copy-Item -Path $originalFilePath -Destination $copyFilePath

        $hashOriginal = Get-FileHashSHA256 -filePath $originalFilePath
        $hashCopy = Get-FileHashSHA256 -filePath $copyFilePath

        $hashOriginal | Should -Be $hashCopy
    }

    It 'calculates different hashes when the file has changed' {
        $testFolder = "$PSScriptRoot\TestFolder"
        New-Item -Path $testFolder -ItemType Directory -Force | Out-Null

        $filePath = Join-Path -Path $testFolder -ChildPath "file.txt"

        "This is the first version of the file." | Out-File -FilePath $filePath -Encoding UTF8
        $hash1 = Get-FileHashSHA256 -filePath $filePath

        "This is the second version of the file." | Out-File -FilePath $filePath -Encoding UTF8
        $hash2 = Get-FileHashSHA256 -filePath $filePath

        $hash1 | Should -Not -Be $hash2
    }

    It 'calculates different hashes for different files' {
        $testFolder = "$PSScriptRoot\TestFolder"
        New-Item -Path $testFolder -ItemType Directory -Force | Out-Null

        $file1Path = Join-Path -Path $testFolder -ChildPath "file1.txt"
        $file2Path = Join-Path -Path $testFolder -ChildPath "file2.txt"

        "This is a test file." | Out-File -FilePath $file1Path -Encoding UTF8
        "This is a different test file." | Out-File -FilePath $file2Path -Encoding UTF8

        $hash1 = Get-FileHashSHA256 -filePath $file1Path
        $hash2 = Get-FileHashSHA256 -filePath $file2Path

        $hash1 | Should -Not -Be $hash2
    }

    It 'throws an error for non-existent file paths' {
        $nonExistentFilePath = "$PSScriptRoot\nonexistentfile.txt"

        { Get-FileHashSHA256 -filePath $nonExistentFilePath } | Should -Throw "Cannot validate argument on parameter 'filePath'.*"
    }

    It 'throws an error for null or empty file paths' {
        { Get-FileHashSHA256 -filePath $null } | Should -Throw "Cannot validate argument on parameter 'filePath'.*"
        { Get-FileHashSHA256 -filePath "" } | Should -Throw "Cannot validate argument on parameter 'filePath'.*"
    }
}