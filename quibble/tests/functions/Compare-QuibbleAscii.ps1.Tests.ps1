Describe 'Test Compare-QuibbleAscii.ps1' {

    Context 'Compare' {
        It 'Compare ASCII Only same strings' {
            $result = Compare-QuibbleAscii -Reference 'ABC' -Difference 'ABC'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be $true
        }

        It 'Compare ASCII Only different strings' {
            $result = Compare-QuibbleAscii -Reference 'ABC' -Difference 'DEF'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be $false
        }

        It 'Compare ASCII Only and Non-ASCII strings as different' {
            $result = Compare-QuibbleAscii -Reference 'ABCDEF' -Difference 'ABCԱԲԳ'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be $false
        }

        It 'Compare ASCII Only and Non-ASCII strings as same' {
            $result = Compare-QuibbleAscii -Reference 'ABCАБВ' -Difference 'ABCԱԲԳ'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be $true
        }
    }
}