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
    }
    Process
    {
        #Remove anything that is not a letter
        $Text = [Regex]::Replace($Text,'[^a-zA-Z]','').ToUpper()
        #Loop though each pair in the text
        For ($Start = 0; $Start -le ($Text.Length - 2); $Start++)
        {
            #Create the pair to use
            $Pair = $Text[$Start..($Start + 1)] -join ''
            #Calculate the entropy
            $Entropy += $Bigrams | Where-Object { $_.Pair -eq $Pair } | Select-Object -ExpandProperty Entropy
        }   
    }
    End
    {
        Return $Entropy
    }
}