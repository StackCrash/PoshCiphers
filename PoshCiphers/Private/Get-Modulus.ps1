Function Get-Modulus 
{
    <# 
        .Synopsis
        Returns the modulus of a dividend and divisor.

        .Description
        Returns the modulus of a dividend and divisor.

        .Parameter Dividend
        The dividend to use.

        .Parameter Divisor
        The divisor to use.

        .Example
        Get-Modulus -Dividend 5 -Divisor 2
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [Int] $Dividend,
        [Parameter(Mandatory = $True, Position=1, ValueFromPipeline=$True)]
        [Int] $Divisor
    )
    #Returns the Modulus of the dividend and divisor
    Return ($Dividend % $Divisor + $Divisor) % $Divisor
}