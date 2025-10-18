<#
Pester tests for Classify-FileStatus function.
These tests assume Pester v5.

They dot-source the `Backup.ps1` module file and mock `Get-FileHashSHA256` to control hash results.
#>

Describe 'Classify-FileStatus' {

    BeforeAll {
        # Dot-source the script under test
        . "$PSScriptRoot\..\Backup.ps1"
    }

    It 'returns New when dedup index is empty' {
        $file = [PSCustomObject]@{ FullName = 'C:\data\file1.txt'; }
        $dedupIndex = [PSCustomObject]@{ Files = @() }

        Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASH1' }

        $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

        $result | Should -Be 'New'
    }

    It 'returns Duplicate when file path not present but hash exists' {
        $file = [PSCustomObject]@{ FullName = 'C:\data\file2.txt'; }
        $dedupIndex = [PSCustomObject]@{ Files = @(
            [PSCustomObject]@{ Hash = 'HASH1'; OriginalPath = 'C:\other\fileA.txt' }
        ) }

        Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASH1' }

        $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

        $result | Should -Be 'Duplicate'
    }

    It 'returns Unchanged when path exists and hash matches' {
        $file = [PSCustomObject]@{ FullName = 'C:\data\fileA.txt'; }
        $dedupIndex = [PSCustomObject]@{ Files = @(
            [PSCustomObject]@{ Hash = 'HASHA'; OriginalPath = 'C:\data\fileA.txt' }
        ) }

        Mock -CommandName Get-FileHashSHA256 -MockWith { 'HASHA' }

        $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

        $result | Should -Be 'Unchanged'
    }

    It 'returns Modified when path exists but hash changed' {
        $file = [PSCustomObject]@{ FullName = 'C:\data\fileA.txt'; }
        $dedupIndex = [PSCustomObject]@{ Files = @(
            [PSCustomObject]@{ Hash = 'OLDHASH'; OriginalPath = 'C:\data\fileA.txt' }
        ) }

        Mock -CommandName Get-FileHashSHA256 -MockWith { 'NEWHASH' }

        $result = Classify-FileStatus -file $file -dedupIndex $dedupIndex

        $result | Should -Be 'Modified'
    }

}
