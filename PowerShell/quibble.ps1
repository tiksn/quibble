#Requires -Module Microsoft.Graph

[CmdletBinding()]
param (
)

try {
    Import-Module -Name Microsoft.Graph
    Import-Module -Name Habitica

    Connect-Graph -Scopes @('Tasks.Read', 'Tasks.ReadWrite')
    $mgUser = Get-MgUser
    Write-Information "Microsoft Graph user is $($mgUser.DisplayName)"

    $habiticaCredentialsFilePath = Join-Path -Path $HOME -ChildPath 'HabiticaCredentials'
    Connect-Habitica -Path $habiticaCredentialsFilePath

    $hUser = Get-HabiticaUser
    Write-Information "Habitica user is $($hUser.profile.name)"

    Get-MgUserTodoList -UserId $mgUser.Id -All
}
catch {
    throw $_
}
