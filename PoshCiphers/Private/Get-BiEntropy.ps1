Function Get-BiEntropy
{
    <# 
        .Synopsis
        Returns the bigram entropy for the supplied text compared to English bigram frequancies.

        .Description
        Returns the bigram entropy for the supplied text compared to English bigram frequancies.

        .Parameter Text
        Text to generate entropy based on.

        .Example
        Get-BiEntropy "Example"
        16.535234171974
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String] $Text
    )
    Begin
    {
        [Double]$Entropy = 0
        $Bigrams = Get-Bigrams
        $Text = $Text.ToUpper()
    }
    Process
    {
        #Loop though each pair in the text
        0..(($Text.ToCharArray()).Length - 2) | ForEach-Object {
            $Pair = $Text.ToCharArray()[$_..($_+1)] -join ''
            $Entropy += $Bigrams | Where-Object { $_.Pair -eq $Pair } | Select-Object -ExpandProperty Entropy
        }
        
    }
    End
    {
        Return $Entropy
    }
}