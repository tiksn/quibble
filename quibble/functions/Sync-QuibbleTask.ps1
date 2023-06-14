
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
        Write-PSFMessage -Level Important -Message "Habitica user is $($hUser.profile.name)"

        Connect-MgGraph -Scopes @('User.Read', 'Tasks.Read', 'Tasks.ReadWrite')
        $msContext = Get-MgContext
        $mgUser = Get-MgUser -UserId $msContext.ClientId
        Write-PSFMessage -Level Important -Message "Microsoft Graph user is $($mgUser.DisplayName)"

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
            Write-PSFMessage -Level SomewhatVerbose -Message "Microsoft To-Do List '$($association.MsTodoList.DisplayName)', Habitica Tag '$($association.HabiticaTag.name)'"
            foreach ($msTodoListTask in $msTodoListTasks) {
                if (-not $msTodoListTask.Recurrence.Pattern.Type) {
                    Write-PSFMessage -Level SomewhatVerbose -Message "Microsoft To-Do '$($msTodoListTask.Title)' $($msTodoListTask.Status)"
                    if ($msTodoListTask.Status -eq 'completed') {
                        foreach ($hTodo in $hTodos) {
                            if (Compare-QuibbleAscii -Reference ($hTodo.text) -Difference ($msTodoListTask.Title)) {
                                Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$($hTodo.text)' will be completed"
                                if ($PSCmdlet.ShouldProcess(
                                        "Habitica To-Do '$($hTodo.text)' will be completed",
                                        $hTodo.text,
                                        'Complete')) {
                                    $hTodo | Complete-HabiticaTask | Out-Null
                                    Write-PSFMessage -Level Important -Message "Habitica To-Do '$($hTodo.text)' with Habitica Tag '$($association.HabiticaTag.name)' completed"
                                    $hTodos = Get-HabiticaTask -Type todos
                                    $hCompletedTodos = Get-HabiticaTask -Type completedTodos
                                }
                            }
                        }
                    }
                    elseif ($msTodoListTask.Status -eq 'notStarted') {
                        $msTodoListTaskTitle = ConvertTo-QuibbleAscii -Source ($msTodoListTask.Title)
                        $hTodo = $hTodos | Where-Object { Compare-QuibbleAscii -Reference ($PSItem.text) -Difference $msTodoListTaskTitle }
                        $hCompletedTodo = $hCompletedTodos | Where-Object { Compare-QuibbleAscii -Reference ($PSItem.text) -Difference ($msTodoListTaskTitle) }
                        if ((-not $hTodo) -and (-not $hCompletedTodo)) {
                            Write-PSFMessage -Level SomewhatVerbose -Message "Habitica To-Do '$msTodoListTaskTitle' will be created"
                            if ($PSCmdlet.ShouldProcess(
                                    "Habitica To-Do '$($msTodoListTaskTitle)' will be created",
                                    $msTodoListTaskTitle,
                                    'Create')) {
                                New-HabiticaTask -Type todo -Tags $association.HabiticaTag.id -Text $msTodoListTaskTitle -Notes $msTodoListTask.Body.Content | Out-Null
                                Write-PSFMessage -Level Important -Message "Habitica To-Do '$($msTodoListTaskTitle)' with Habitica Tag '$($association.HabiticaTag.name)' created"
                                $hTodos = Get-HabiticaTask -Type todos
                                $hCompletedTodos = Get-HabiticaTask -Type completedTodos
                            }
                        }
                    }
                }
            }

            if ($Bidirectional) {
                Start-Sleep -Seconds 60
                $msTodoListTasks = Get-MgUserTodoListTask -TodoTaskListId $association.MsTodoList.Id -UserId $mgUser.Id -All
                $hTodos = Get-HabiticaTask -Type todos

                $hCurrentTagTodos = $hTodos | Where-Object { $PSItem.tags -contains $association.HabiticaTag.id }

                foreach ($hTodo in $hCurrentTagTodos) {
                    if (-not ($msTodoListTasks | Where-Object { Compare-QuibbleAscii -Reference ($PSItem.Title) -Difference ($hTodo.text) })) {
                        $hTodoText = $hTodo.text
                        $hTodoNotes = $hTodo.notes
                        Write-PSFMessage -Level SomewhatVerbose -Message "Microsoft To-Do '$hTodoText' will be created"
                        if ($PSCmdlet.ShouldProcess(
                                "Microsoft To-Do '$($hTodoText)' will be created",
                                $hTodoText,
                                'Create')) {
                            $msTodoListTaskBody = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphItemBody]::new()
                            $msTodoListTaskBody.Content = $hTodoNotes
                            $msTodoListTaskBody.ContentType = 'text'
                            New-MgUserTodoListTask -TodoTaskListId $association.MsTodoList.Id -UserId $mgUser.Id -Title $hTodoText -Body $msTodoListTaskBody | Out-Null
                            Write-PSFMessage -Level Important -Message "Microsoft To-Do '$($hTodoText)' in Microsoft To-Do List '$($association.MsTodoList.DisplayName)' created"
                            $msTodoListTasks = Get-MgUserTodoListTask -TodoTaskListId $association.MsTodoList.Id -UserId $mgUser.Id -All
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