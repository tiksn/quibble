Describe 'Test Sync-QuibbleTask.ps1' {
    if (-not $env:CI) {
        
        Context 'Sync' {
            It 'Sync Task' {
                Sync-QuibbleTask
            }
        }
    }
}