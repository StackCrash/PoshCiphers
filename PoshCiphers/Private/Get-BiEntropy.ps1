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
        $Message = ([RegEx]::Matches($Text,'[a-zA-Z]+') | ForEach-Object { $_.Value }).ToUpper() -join ''
    }
    Process
    { 
       #Loop though each pair in the text
        For ($i = 0; $i -lt (($Message.ToCharArray()).Length - 2); $i++)
        {
            #Create the pair to use
            $Pair = $Message.ToCharArray()[$i..($i+1)] -join ''
            #Calculate the entropy
            $Entropy += $Bigrams | Where-Object { $_.Pair -eq $Pair } | Select-Object -ExpandProperty Entropy
        }   
    }
    End
    {
        Return $Entropy
    }
}