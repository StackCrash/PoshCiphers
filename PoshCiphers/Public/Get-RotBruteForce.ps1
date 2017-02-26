Function Get-RotBruteForce
{
    <# 
        .Synopsis
        Brute forces the deciphering of message(s) that has been enciphered with a rotation based cipher.

        .Description
        Brute forces the deciphering of message(s) that has been enciphered with a rotation based cipher.

        .Parameter Ciphertext
        The enciphered message(s) to be deciphered.

        .Parameter Return
        The number of potential matches returned. 
            Default value is 1.
        
        .Parameter Strip
        Removes whitespaces from the ciphertext message(s).

        .Parameter Bigrams
        Uses bigrams to calculate the entropy instead of single letter entropy

        .Example
        Get-RotBruteForce -Ciphertext "Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr"

        Plaintext                                     Ciphertext                                    Rotation           Entropy
        ---------                                     ----------                                    --------           ------
        This is an example that should be long enough Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr       10 109.798786942039

        .Example
        Get-RotBruteForce -Ciphertext "Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr" -Strip

        Plaintext                             Ciphertext                            Rotation           Entropy
        ---------                             ----------                            --------           ------
        Thisisanexamplethatshouldbelongenough Drscsckxohkwzvodrkdcryevnlovyxqoxyeqr       10 109.798786942039

        .Example
        Get-RotBruteForce -Ciphertext "Ohkwzvo" -Return 6

        Plaintext Ciphertext Rotation           Entropy
        --------- ---------- --------           ------
        Atwilha   Ohkwzvo          14 19.8330281092882
        Lehtwsl   Ohkwzvo           3 20.1951620075682
        Hadpsoh   Ohkwzvo           7 20.5561918374628
        Tmpbeat   Ohkwzvo          21 21.2523902999804
        Wpsehdw   Ohkwzvo          18 22.2203513815375
        Example   Ohkwzvo          10 24.0221984573182

        .Example
        Get-RotBruteForce -Ciphertext "Qjmybxq" -Bigrams -Return 4

        Plaintext Ciphertext Rotation          Entropy
        --------- ---------- --------          -------
        Atwilha   Qjmybxq          16 15.0861096952459
        Tmpbeat   Qjmybxq          23 16.1689118339204
        Hadpsoh   Qjmybxq           9 16.3222746155573
        Example   Qjmybxq          12  16.535234171974

        .NOTES
        The length of the ciphertext is important because shorter ciphertext will increase the chance of an inaccurate result.

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Ciphertext,
        [Parameter(Mandatory = $False, Position=1)]
        [ValidateRange(1,25)]
        [Int] $Return = 1,
        [Parameter()]
        [Switch]$Strip,
        [Parameter()]
        [Switch]$Bigrams
    )
    Begin
    {
        #Create an array list to store results in
        $DecipheredMessages = New-Object System.Collections.ArrayList
    }
    Process
    {
        #Loop through each ciphertext
        ForEach ($Message in $Ciphertext)
        {
            #Create an array list to store deciphered characters in
            $DecipheredArray = New-Object System.Collections.ArrayList
            #Create an array list to store deciphered characters in
            If ($Strip)
            {
                #Remove whitespaces
                $Message = $Message -replace '\s', ''
            }
            #Decipher all possible rotations of the message
            $Deciphered = 1..25 | ForEach-Object { Get-RotDecipher -Ciphertext $Message -Rotation $_ }
            #Loop through each deciphered message and generate the entroy
            ForEach ($Text in $Deciphered)
            {
                If ($Bigrams)
                {
                    #Get the bigram entropy for the plaintext
                    $Entropy = (Get-BiEntropy -Text $($Text | Select-Object -ExpandProperty Plaintext))
                    #Add results to a the $DecipheredArray
                    $DecipheredArray.Add(([PSCustomObject]@{
                        'Plaintext' = $Text | Select-Object -ExpandProperty Plaintext
                        'Ciphertext' = $Text | Select-Object -ExpandProperty Ciphertext
                        'Rotation' = $Text | Select-Object -ExpandProperty Rotation
                        'Entropy' = $Entropy
                    })) | Out-Null
                }
                Else
                {
                    #Get the entropy for the plaintext
                    $Entropy = (Get-Entropy -Text $($Text | Select-Object -ExpandProperty Plaintext))
                    #Add results to a the $DecipheredArray
                    $DecipheredArray.Add(([PSCustomObject]@{
                        'Plaintext' = $Text | Select-Object -ExpandProperty Plaintext
                        'Ciphertext' = $Text | Select-Object -ExpandProperty Ciphertext
                        'Rotation' = $Text | Select-Object -ExpandProperty Rotation
                        'Entropy' = $Entropy
                    })) | Out-Null
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