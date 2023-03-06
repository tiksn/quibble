Describe 'Test ConvertTo-QuibbleAscii.ps1' {

    Context 'Convert' {
        It 'Same as original' {
            $result = ConvertTo-QuibbleAscii -Source 'ABC'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'ABC'
        }

        It 'Fill out question marks' {
            $result = ConvertTo-QuibbleAscii -Source 'ABCԱԲԳ'

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Be 'ABC???'
        }
    }
}