#For PowerShell v3
Function gig {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$list
    )
    $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ','
    Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$params"
    | Select-Object -ExpandProperty content | Out-File -FilePath $(Join-Path -Path $pwd -ChildPath '.gitignore') -Encoding ascii
}

gig -list visualstudiocode, powershell

Write-Output '# ignore the TestResults' | Out-File -Append -FilePath .\.gitignore
Write-Output 'TestResults/*' | Out-File -Append -FilePath .\.gitignore
Write-Output '' | Out-File -Append -FilePath .\.gitignore
Write-Output '# ignore the publishing Directory' | Out-File -Append -FilePath .\.gitignore
Write-Output 'publish/*' | Out-File -Append -FilePath .\.gitignore
Write-Output '' | Out-File -Append -FilePath .\.gitignore
Write-Output '# Project Specific' | Out-File -Append -FilePath .\.gitignore
Write-Output '.trash' | Out-File -Append -FilePath .\.gitignore
