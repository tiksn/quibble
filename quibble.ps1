[CmdletBinding()]
param (
)

try {
    Import-Module -Name Microsoft.Graph

    Connect-Graph -Scopes @("Tasks.ReadWrite")
    $mgUser = Get-MgUser

    Write-Host "Microsoft Graph user is $($mgUser.DisplayName)"
    Get-MgUserTodoList -UserId $mgUser.Id
}
catch {
    throw $_
}
