<#
Testy Pester dla funkcji Classify-FileStatus.
Te testy zakładają Pester w wersji 5.
Dot-source'ują plik modułu `Deduplication.psm1` oraz mockują `Get-FileHashSHA256`, aby kontrolować wyniki hashy.

Testowane są następujące scenariusze:
1. Gdy indeks deduplikacji jest pusty, funkcja powinna zwrócić 'New'.
2. Gdy ścieżka pliku nie istnieje, ale hash istnieje w indeksie, funkcja powinna zwrócić 'Duplicate'.
3. Gdy ścieżka pliku istnieje i hash się zgadza, funkcja powinna zwrócić 'Unchanged'.
4. Gdy ścieżka pliku istnieje, ale hash się zmienił, funkcja powinna zwrócić 'Modified'.
#>

Describe 'Classify-FileStatus' {

    BeforeAll {
        # Dot-source'ing funkcji 
        . "$PSScriptRoot\..\Deduplication\Functions\Get-FileHashSHA256.ps1"
        . "$PSScriptRoot\..\Deduplication\Functions\Classify-FileStatus.ps1"
    }

    Context 'Positive tests' {
        It 'returns "New" when dedup index is empty' {
            $file = [PSCustomObject]@{ FullName = 'C:\data\file1.txt'; }
            $dedupIndex = [PSCustomObject]@{ Files = @() }

            Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASH1' }
            Mock -CommandName Test-Path -MockWith { $true }

            $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

            $result | Should -Be 'New'
        }

        It 'returns "Duplicate" when file path not present but hash exists' {
            $file = [PSCustomObject]@{ FullName = 'C:\data\file2.txt'; }
            $dedupIndex = [PSCustomObject]@{ Files = @(
                    [PSCustomObject]@{ Hash = 'HASH1'; OriginalPath = 'C:\other\fileA.txt' }
                ) 
            }

            Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASH1' }
            Mock -CommandName Test-Path -MockWith { $true }

            $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

            $result | Should -Be 'Duplicate'
        }

        It 'returns "New" when file path and hash both do not exist' {
            $file = [PSCustomObject]@{ FullName = "C:\data\NewFile.txt"; }
            $dedupIndex = [PSCustomObject]@{ Files = @(
                    [PSCustomObject]@{ Hash = 'HASH2'; OriginalPath = 'C:\other\fileB.txt' }
                ) 
            }
        
            Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASH1' }
            Mock -CommandName Test-Path -MockWith { $true }

            $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

            $result | Should -Be 'New'
        }

        It 'returns "Unchanged" when path exists and hash matches' {
            $file = [PSCustomObject]@{ FullName = 'C:\data\fileA.txt'; }
            $dedupIndex = [PSCustomObject]@{ Files = @(
                    [PSCustomObject]@{ Hash = 'HASHA'; OriginalPath = 'C:\data\fileA.txt' }
                ) 
            }

            Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASHA' }
            Mock -CommandName Test-Path -MockWith { $true }

            $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

            $result | Should -Be 'Unchanged'
        }

        It 'returns "Modified" when path exists but hash changed' {
            $file = [PSCustomObject]@{ FullName = 'C:\data\fileA.txt'; }
            $dedupIndex = [PSCustomObject]@{ Files = @(
                    [PSCustomObject]@{ Hash = 'OLDHASH'; OriginalPath = 'C:\data\fileA.txt' }
                ) 
            }

            Mock -CommandName Get-FileHashSHA256 -MockWith { 'NEWHASH' }
            Mock -CommandName Test-Path -MockWith { $true }

            $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

            $result | Should -Be 'Modified'
        } 
    }
    Context 'Negative tests' {
        It 'throw "Cannot validate argument..." when file input is null' {
            $dedupIndex = [PSCustomObject]@{ Files = @() }

            { Classify-FileStatus -file $null -dedupIndex $dedupIndex } | Should -Throw "Cannot validate argument on parameter 'file'*."
        }

        It 'throw "Cannot validate argument..." when dedupIndex input is null' {
            $file = [PSCustomObject]@{ FullName = 'C:\data\file1.txt'; }

            Mock -CommandName Test-Path -MockWith { $true }

            { Classify-FileStatus -file $file -dedupIndex $null } | Should -Throw "Cannot validate argument on parameter 'dedupIndex'*" 
        }

        It 'throw "Cannot validate argument..." when file path does not exist' {
            $file = [PSCustomObject] @{ FullName = 'C:\data\nonexistentfile.txt'; }
            $dedupIndex = [PSCustomObject]@{ Files = @() }

            Mock -CommandName Test-Path -MockWith { $false }

            { Classify-FileStatus -file $file -dedupIndex $dedupIndex } | Should -Throw "Cannot validate argument on parameter 'file'*" 
        }
    }
}
