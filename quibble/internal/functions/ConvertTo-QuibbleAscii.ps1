function ConvertTo-QuibbleAscii {
<#
    .SYNOPSIS
        Convert String to ASCII

    .DESCRIPTION
        Convert String to ASCII

    .PARAMETER Source
        Source String

    .NOTES

    .LINK
        https://github.com/tiksn/quibble

    .EXAMPLE
        ConvertTo-QuibbleAscii -Source 'ABC'

        Convert String to ASCII
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Source
    )

    begin {

    }

    process {
        $targetEncoding = [System.Text.Encoding]::ASCII
        $sourceEncoding = [System.Text.Encoding]::UNICODE

        $sourceBytes = $sourceEncoding.GetBytes($Source)
        $convertedBytes = [System.Text.Encoding]::Convert([System.Text.Encoding]::UNICODE, $targetEncoding, $sourceBytes)
        $targetEncoding.GetString($convertedBytes)
    }

    end {

    }
}