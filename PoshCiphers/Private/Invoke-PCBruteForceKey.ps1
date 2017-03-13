Function Invoke-PCBruteForceKey
{
    <# 
        .Synopsis
        Brute forces the best vigenere cipher key for a given keylength.

        .Description
        Brute forces the best vigenere cipher key for a given keylength.

        .Parameter Ciphertext
        Ciphertext to brute force the key from.

        .Parameter KeyLength
        Key length to brute force

        .Example
        Invoke-PCBruteForceKey -Ciphertext 'TpczwxviXzkxfitvgkwevvhtnitpwbetnvgbhlgixasxkjqhvitrxxdcfzjyagwcxygvcecnfmpkigvifgeklmgjxhvieztawv' -KeyLength 6
        SECRET

        .NOTES
        The length of the ciphertext is important because shorter ciphertext will increase the chance of an inaccurate result.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String] $Ciphertext,
        [Parameter(Mandatory = $True, Position=1, ValueFromPipeline=$True)]
        [ValidateRange(2,99)]
        [Int] $KeyLength
    )
    Begin
    {
        #Remove anything that is not a letter
        $Ciphertext = [Regex]::Replace($Ciphertext,'[^a-zA-Z]','').ToUpper()
        #Array list to store the key in
        $Key = New-Object System.Collections.ArrayList
        #Bigram square with entropy values to use when generating entropy
        $BigramSqaure = Get-PCBigramSquare
        #Array with alphabet to generate bigrams from
        $Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
    }
    Process
    {
        #Object to hold the best bigram and its entropy
        $Best = [PSCustomObject]@{
            'First' = ''
            'Second' = ''
            #Generates a large entrpoy initially so any pair will be better initially
            'Entropy' = [Math]::Pow(10,10)
        }
        #Loop through each index in the key
        ForEach ($KeyIndex in 0..($KeyLength - 1))
        {
            #Reset best entropy
            $Best.Entropy = [Math]::Pow(10,10)
            #Loop through the first half of the bigrams
            ForEach ($First in $Alphabet)
            {
                #Loop through the second half of the bigrams
                ForEach ($Second in $Alphabet)
                {
                    $Bigram = $First + $Second
                    $Entropy = 0
                    #Gets an array with the ciphertext start for a vigenere square
                    $Filter = Get-PCVigenereFilter -Key $Bigram | ForEach-Object { (26 - $_) % 26 }
                    
                    #Generates the starting indexes for the current key index
                    $Sequence = For ($i = $KeyIndex; $i -lt ($Ciphertext.Length - 1); $i += $KeyLength) { $i }
                    ForEach ($Index in $Sequence)
                    {
                        #Gets the plaintext value for the first part of the bigram at a given index
                        $FirstPlain = ([Byte]$Ciphertext[$Index] - 65 + $Filter[0]) % 26
                        #Gets the plaintext value for the second part of the bigram at a given index
                        $SecondPlain = ([Byte]$Ciphertext[$Index + 1] - 65 + $Filter[1]) % 26
                        #Adds the entropy for the plaintext bigram to the key bigram's entropy
                        $Entropy += $BigramSqaure[$FirstPlain][$SecondPlain]
                    }
                    #Checks if the key bigram's entropy is best entropy
                    If ($Entropy -lt $Best.Entropy)
                    {
                        $Best.First = $First
                        $Best.Second = $Second
                        $Best.Entropy = $Entropy
                    }
                }
            }
            If ($KeyIndex -eq 0)
            {
                #Object to hold the first index of the key
                $Zero = [PSCustomObject]@{
                    'First' = $Best.First
                    'Second' = $Best.Second
                    'Entropy' = $Best.Entropy
                }
                #Push the first letter of the key to the key array
                $Key.Add($Zero.First) | Out-Null
            }
            ElseIf ($KeyIndex -eq ($KeyLength - 1))
            {
                #If last index in key add the first best
                $Key.Add($Best.First) | Out-Null
            }
            Else
            {
                #Checks if previous is better then current and stores previous is true
                If ($Previous.Entropy -le $Best.Entropy) { $Key.Add($Previous.Second) | Out-Null }
                Else { $Key.Add($Best.First) | Out-Null }
            }
            #Object to hold the previous best bigram
            $Previous =  [PSCustomObject]@{
                'First' = $Best.First
                'Second' = $Best.Second
                'Entropy' = $Best.Entropy
            }   
        }
        #Checks if last best bigram is better then key index zero
        If ($Best.Entropy -lt $Zero.Entropy) { $Key[0] = $Best.Second }
    }
    End
    {
        [String]$Key = $Key -join ''
        Return $Key
    }
}