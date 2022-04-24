
<#PSScriptInfo

.VERSION 1.0.0

.GUID 9b7358ea-945f-401d-a211-fe02d722d1a5

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME TIKSN Lab

.COPYRIGHT Tigran TIKSN Torosyan

.TAGS

.LICENSEURI https://github.com/tiksn/quibble/blob/develop/LICENSE

.PROJECTURI https://github.com/tiksn/quibble

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#> 

#Requires -Module Microsoft.Graph
#Requires -Module Habitica









<# 

.DESCRIPTION 
 Synchronize Microsoft To Do tasks and Habitica todos 

#> 
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
    $habiticaCredentialsFileExists = Test-Path -Path $habiticaCredentialsFilePath
    if ($habiticaCredentialsFileExists) {
        Connect-Habitica -Path $habiticaCredentialsFilePath
    }
    else {
        Connect-Habitica -Path $habiticaCredentialsFilePath -Save
    }

    $hUser = Get-HabiticaUser
    Write-Information "Habitica user is $($hUser.profile.name)"

    Get-MgUserTodoList -UserId $mgUser.Id -All
}
catch {
    throw $_
}
