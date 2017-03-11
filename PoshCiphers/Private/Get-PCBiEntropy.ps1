Function Get-PCBiEntropy
{
    <# 
        .Synopsis
        Returns the bigram entropy for the supplied text compared to English bigram frequancies.

        .Description
        Returns the bigram entropy for the supplied text compared to English bigram frequancies.
        Bigram frequencies taken from http://practicalcryptography.com/media/cryptanalysis/files/english_bigrams_1.txt and normalized as logarithms.

        .Parameter Text
        Text to generate entropy based on.

        .Example
        Get-PCBiEntropy -Text "Example"
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
        $Bigrams = Get-PCBigramSquare
    }
    Process
    {
        #Remove anything that is not a letter
        $Text = [Regex]::Replace($Text,'[^a-zA-Z]','').ToUpper()
        #Loop though each pair in the text
        ForEach ($Start in 0..($Text.Length - 2))
        {
            #Create the pair to use
            $Pair = $Text[$Start..($Start + 1)]
            #Calculate the entropy
            $Entropy += $Bigrams[($Pair[0] - 65)][($Pair[1] - 65)]
        }   
    }
    End
    {
        Return $Entropy
    }
}