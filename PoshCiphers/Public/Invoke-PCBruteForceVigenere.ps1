Function Invoke-PCBruteForceVigenere
{
    <# 
        .Synopsis
        Brute forces the best vigenere cipher key for a given keylength range.

        .Description
        Brute forces the best vigenere cipher key for a given keylength range.

        .Parameter Ciphertext
        Ciphertext to brute force the key from.

        .Parameter MinKeyLength
        Minimum key length to brute force.
            Default value is 3.

        .Parameter MaxKeyLength
        Maximum key length to brute force.
            Default value is 30.

        .Parameter Return
        The number of potential matches returned. 
            Default value is 1.

        .Parameter Strip
        Removes whitespaces from the ciphertext message(s).

        .Example
        Invoke-PCBruteForceVigenere -Ciphertext 'Zls tnsogs wuv sebborj pwvy fkxkvkr lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh sapq st dgrqmbu nevtwekwy mg skxzif' -Return 2

        PlainText                                Ciphertext                               Key                                                     Entropy
        ---------                                ----------                               ---                                                     -------
        The choice for mankind lies between      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORGE                                                  184.669755696769
        freedom and happiness and for the great  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
        bulk of mankind happiness is better      sapq st dgrqmbu nevtwekwy mg skxzif
        The cibmue lor nanaind liet oilwken      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORFRCMOLGEFEOBGE                                      185.186639807148
        greudom and inthitest ant for the heist  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
        hull of cankind inthitest is retter      sapq st dgrqmbu nevtwekwy mg skxzif

        .Example
        Invoke-PCBruteForceVigenere -Ciphertext 'Zls tnsogs wuv sebborj pwvy fkxkvkr lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh sapq st dgrqmbu nevtwekwy mg skxzif' -MaxKeyLength 10

        PlainText                                Ciphertext                               Key                                                     Entropy
        ---------                                ----------                               ---                                                     -------
        The choice for mankind lies between      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORGE                                                  184.669755696769
        freedom and happiness and for the great  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
        bulk of mankind happiness is better      sapq st dgrqmbu nevtwekwy mg skxzif

        .Example
        Invoke-PCBruteForceVigenere -Ciphertext 'Zls tnsogs wuv sebborj pwvy fkxkvkr lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh sapq st dgrqmbu nevtwekwy mg skxzif' -Strip

        PlainText                                Ciphertext                               Key                                                     Entropy
        ---------                                ----------                               ---                                                     -------
        Thechoiceformankindliesbetweenfreedomand Zlstnsogswuvsebborjpwvyfkxkvkrlvsvjssebu GEORGE                                                  184.669755696769
        happinessandforthegreatbulkofmankindhapp nevtwekwyebulsxxvvmvkehsapqstdgrqmbunevt
        inessisbetter                            wekwymgskxzif

        .NOTES
        The length of the ciphertext is important because shorter ciphertext will increase the chance of an inaccurate result.
        Too high of a maximum key length can also cause an inaccurate result.

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Ciphertext,
        [Parameter(Mandatory = $False, Position=1, ValueFromPipeline=$True)]
        [ValidateRange(2,99)]
        [Int] $MinKeyLength = 3,
        [Parameter(Mandatory = $False, Position=2, ValueFromPipeline=$True)]
        [ValidateRange(2,99)]
        [Int] $MaxKeyLength = 30,
        [Parameter(Mandatory = $False, Position=3)]
        [ValidateRange(1,99)]
        [Int] $Return = 1,
        [Parameter(Mandatory = $False)]
        [Switch]$Strip
    )
    Begin
    {
        #Check if MaxKeyLength is less than MinKeyLength
        If ($MaxKeyLength -lt $MinKeyLength)
        {
            Write-Error -Message "MaxKeyLength must be equal to or greater than MinKeyLength."
            Break
        }
        #Create an array list to store results in
        $DecipheredMessages = New-Object System.Collections.ArrayList
    }
    Process
    {
        #Loop through each ciphertext
        ForEach ($Message in $Ciphertext)
        {
            $CipherLen = [Regex]::Replace($Message,'[^a-zA-Z]','').Length
            If ($CipherLen -lt $MaxKeyLength) { $MaxKeyLength = $CipherLen}
            #Create an array list to store deciphered characters in
            $DecipheredArray = New-Object System.Collections.ArrayList
            #Create an array list to store deciphered characters in
            If ($Strip)
            {
                #Remove whitespaces
                $Message = $Message -replace '\s', ''
            }
            $Factors = Invoke-PCKasiskiExam -Ciphertext $Message | Sort-Object -Property Factor
            #If Kasiski examination returned factors
            If ($Factors)
            {
                #Removes any factors greater than the max key length
                $Factors = $Factors | Where-Object { [Int]$_.Factor -le $MaxKeyLength }
                Foreach ($Factor in $Factors)
                {
                    $KeyLength = $Factor | Select-Object -ExpandProperty Factor
                    $Key = Invoke-PCBruteForceKey -Ciphertext $Message -KeyLength $KeyLength
                    $PlainText = Invoke-PCVigenereDecipher -Ciphertext $Message -Key $Key | Select-Object -ExpandProperty PlainText
                    $Entropy = Get-PCBigramEntropy -Text $PlainText
                    #Adjust the entropy based on the factor's weight
                    $Entropy = $Entropy - $Entropy * $Factor.Weight

                    $Result = [PSCustomObject]@{
                        'Plaintext' = $PlainText
                        'Ciphertext' = $Message
                        'Key' = $Key
                        'Entropy' = $Entropy
                    }
                    $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Vigenere.Brute')
                    #Add results to a the $DecipheredArray
                    $DecipheredArray.Add($Result) | Out-Null
                }
            }
            #If Kasiski examination did not return factors
            Else
            {
                ForEach ($KeyLength in $MinKeyLength..($MaxKeyLength + 1))
                {
                    $Key = Invoke-PCBruteForceKey -Ciphertext $Message -KeyLength $KeyLength
                    $PlainText = Invoke-PCVigenereDecipher -Ciphertext $Message -Key $Key | Select-Object -ExpandProperty PlainText
                    $Entropy = Get-PCBigramEntropy -Text $PlainText

                    $Result = [PSCustomObject]@{
                        'Plaintext' = $PlainText
                        'Ciphertext' = $Message
                        'Key' = $Key
                        'Entropy' = $Entropy
                    }
                    $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Vigenere.Brute')
                    #Add results to a the $DecipheredArray
                    $DecipheredArray.Add($Result) | Out-Null
                }
            }
            #Add the number of desired returns after sorting the $DecipheredArray
           $DecipheredMessages.Add(($DecipheredArray | Sort-Object -Property Entropy | Select-Object -First $Return)) | Out-Null
        }
    }
    End
    {
        #Return the results
        Return $DecipheredMessages
    }
}