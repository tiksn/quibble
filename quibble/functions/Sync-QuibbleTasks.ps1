
function Sync-QuibbleTasks {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    param (
    )
    
    try {
        Connect-Graph -Scopes @('User.Read','Tasks.Read', 'Tasks.ReadWrite')
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
            $msTodoListTasks = Get-MgUserTodoListTask -TodoTaskListId $association.MsTodoList.Id -UserId $mgUser.Id
            foreach ($msTodoListTask in $msTodoListTasks) {
                if (-not $msTodoListTask.Recurrence.Pattern.Type) {
                    if ($msTodoListTask.Status -eq 'completed') {
                        foreach ($hTodo in $hTodos) {
                            if ($hTodo.text -eq $msTodoListTask.Title) {
                                if ($PSCmdlet.ShouldProcess(
                                        "Habitica To-Do '$($hTodo.text)' will be completed",
                                        $hTodo.text,
                                        'Complete')) {
                                    $hTodo | Complete-HabiticaTask
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
                        $msTodoListTaskTitle = $msTodoListTaskTitle.Replace("", "")
                        $hTodo = $hTodos | Where-Object { $PSItem.text -eq $msTodoListTaskTitle }
                        $hCompletedTodo = $hCompletedTodos | Where-Object { $PSItem.text -eq $msTodoListTaskTitle }
                        if ((-not $hTodo) -and (-not $hCompletedTodo)) {
                            if ($PSCmdlet.ShouldProcess(
                                    "Habitica To-Do '$($msTodoListTaskTitle)' will be created",
                                    $msTodoListTaskTitle,
                                    'Create')) {
                                New-HabiticaTask -Type todo -Tags $association.HabiticaTag.id -Text $msTodoListTaskTitle -Notes $msTodoListTask.Body.Content
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