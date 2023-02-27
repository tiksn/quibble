
function Sync-QuibbleTask {
<#
    .SYNOPSIS
        Synchronize Microsoft To Do tasks and Habitica todos

    .DESCRIPTION
        Synchronize Microsoft To Do tasks and Habitica todos

    .PARAMETER Confirm
		Confirm to proceed synchronization

    .PARAMETER Bidirectional
        Synchronize Microsoft To Do tasks and Habitica todos Bidirectionally

    .PARAMETER WhatIf
		Dry-Run the synchronization

    .NOTES

    .LINK
        https://github.com/tiksn/quibble

    .EXAMPLE
        Sync-QuibbleTask -Verbose

        Synchronize all to-dos
#>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    param (
        [Parameter()]
        [switch]
        $Bidirectional
    )
    
    try {
        $habiticaCredentialSecretName = Get-PSFConfigValue -FullName quibble.Secrets.HabiticaCredentialSecretName -NotNull
        [pscredential]$habiticaCredential = Get-Secret -Name $habiticaCredentialSecretName
        if ($null -eq $habiticaCredential) {
            throw 'Habitica Credential is null'
        }
        if ($IsLinux -or $IsMacOS) {
            $habiticaCredentialPlain = [PSCustomObject] @{
                UserName = $habiticaCredential.UserName
                Password = $habiticaCredential.GetNetworkCredential().Password
            }
            [PSCustomObject]$habiticaCredential = $habiticaCredentialPlain
        }
        Connect-Habitica -Credential $habiticaCredential
        $hUser = Get-HabiticaUser
        Write-Information "Habitica user is $($hUser.profile.name)"

        Connect-MgGraph -Scopes @('User.Read', 'Tasks.Read', 'Tasks.ReadWrite')
        $mgUser = Get-MgUser
        Write-Information "Microsoft Graph user is $($mgUser.DisplayName)"   
    
        $msLists = Get-MgUserTodoList -UserId $mgUser.Id -All
    
        $hTags = Get-HabiticaTag
        $hTodos = Get-HabiticaTask -Type todos
        $hCompletedTodos = Get-HabiticaTask -Type completedTodos
    
        $associations = @()
    
        foreach ($msList in $msLists) {
            if ($msList.IsOwner -and ($msList.WellknownListName -eq 'none')) {
                foreach ($hTag in $hTags) {
                    if ($msList.DisplayName.Contains($hTag.name)) {
                        $associations += [PSCustomObject]@{
                            MsTodoList  = $msList
                            HabiticaTag = $hTag
                        }
                    }
                }
            }
        }
    
        foreach ($association in $associations) {
            $msTodoListTasks = Get-MgUserTodoListTask -TodoTaskListId $association.MsTodoList.Id -UserId $mgUser.Id -All
            Write-PSFMessage -Level SomewhatVerbose -Message "Microsoft To-Do List '$($association.MsTodoList.DisplayName)'"
            foreach ($msTodoListTask in $msTodoListTasks) {
                if (-not $msTodoListTask.Recurrence.Pattern.Type) {
                    Write-PSFMessage -Level SomewhatVerbose -Message "Microsoft To-Do '$($msTodoListTask.Title)' $($msTodoListTask.Status)"
                    if ($msTodoListTask.Status -eq 'completed') {
                        foreach ($hTodo in $hTodos) {
                            if ($hTodo.text -eq $msTodoListTask.Title) {
                                Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$($hTodo.text)' will be completed"
                                if ($PSCmdlet.ShouldProcess(
                                        "Habitica To-Do '$($hTodo.text)' will be completed",
                                        $hTodo.text,
                                        'Complete')) {
                                    $hTodo | Complete-HabiticaTask
                                    Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$($hTodo.text)' completed"
                                }
                            }
                        }
                    }
                    elseif ($msTodoListTask.Status -eq 'notStarted') {
                        $msTodoListTaskTitle = $msTodoListTask.Title.Normalize([System.Text.NormalizationForm]::FormD)
                        $msTodoListTaskTitle = $msTodoListTaskTitle.Replace("’", "'")
                        $uni = [System.Text.Encoding]::Unicode.GetBytes($msTodoListTaskTitle)
                        $ascii = [System.Text.Encoding]::ASCII.GetString($uni)
                        $msTodoListTaskTitle = $ascii.Normalize([System.Text.NormalizationForm]::FormD)
                        $msTodoListTaskTitle = $msTodoListTaskTitle.Replace("$([char]0x0000)", '')
                        $msTodoListTaskTitle = $msTodoListTaskTitle.Replace('', '')
                        $hTodo = $hTodos | Where-Object { $PSItem.text -eq $msTodoListTaskTitle }
                        $hCompletedTodo = $hCompletedTodos | Where-Object { $PSItem.text -eq $msTodoListTaskTitle }
                        if ((-not $hTodo) -and (-not $hCompletedTodo)) {
                            Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$msTodoListTaskTitle' will be created"
                            if ($PSCmdlet.ShouldProcess(
                                    "Habitica To-Do '$($msTodoListTaskTitle)' will be created",
                                    $msTodoListTaskTitle,
                                    'Create')) {
                                New-HabiticaTask -Type todo -Tags $association.HabiticaTag.id -Text $msTodoListTaskTitle -Notes $msTodoListTask.Body.Content
                                Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$msTodoListTaskTitle' created"
                            }
                        }
                    }
                }
            }
        }
    }
    catch {
        throw $_
    }
    
}