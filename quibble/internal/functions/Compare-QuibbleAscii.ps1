function Compare-QuibbleAscii {
<#
    .SYNOPSIS
        Compare Strings as ASCII

    .DESCRIPTION
        Compare Strings as ASCII

    .PARAMETER Reference
        Reference String

    .PARAMETER Difference
        Difference String

    .NOTES

    .LINK
        https://github.com/tiksn/quibble

    .EXAMPLE
        Compare-QuibbleAscii -Reference 'ABC' -Difference 'DEF'

        Compare Strings as ASCII
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Reference,
        [Parameter(Mandatory = $true)]
        [string]
        $Difference
    )

    begin {

    }

    process {
        $targetReference = ConvertTo-QuibbleAscii -Source $Reference
        $targetDifference = ConvertTo-QuibbleAscii -Source $Difference

        $targetReference -eq $targetDifference
    }

    end {

    }
}