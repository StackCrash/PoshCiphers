Function Invoke-PCVigenereDecipher
{
    <# 
        .Synopsis
        Deciphers message(s) that has been enciphered with a Vigenere cipher.

        .Description
        Deciphers message(s) that has been enciphered with a Vigenere cipher.

        .Parameter Ciphertext
        The enciphered message(s) to be deciphered.

        .Parameter Key
        The key to use in the deciphering.
        Note: The key is case-insensitive.
        
        .Parameter Strip
        Removes whitespaces from the ciphertext message(s).

        .Example
        Invoke-PCVigenereDecipher -Ciphertext "Txselzv" -Key "password"

        Plaintext Ciphertext Key
        --------- ---------- ---
        Example   Txselzv    password

        .Example
        Invoke-PCVigenereDecipher -Ciphertext "Txse lzvZ xtzK loth h" -Key "password" -Strip

        Plaintext         Ciphertext        Key
        ---------         ----------        ---
        ExampleWithSpaces TxselzvZxtzKlothh password

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Ciphertext,
        [Parameter(Mandatory = $True, Position=1)]
        [String] $Key,
        [Parameter(Mandatory = $False, Position=2)]
        [String] $Spacing = 0,
        [Parameter(Mandatory = $False)]
        [Switch]$Strip
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
            $Deciphered = New-Object System.Collections.ArrayList
            #Get the Vigenere table for the key
            $Filter = Get-PCVigenereFilter -Key $Key | ForEach-Object { (26 - $_) % 26 }
            #Set the index value to use with the filter
            $FilterIndex = 0
            If ($Strip)
            {
                #Remove whitespaces
                $Message = $Message -replace '\s', ''
            }
            #Loop though each character in the message
            ForEach ($Character in $Message.ToCharArray())
            {
                #Convert the character to ASCII code
                Switch ([Byte]$Character)
                {
                    #Decipher uppercase characters
                    {$_ -ge 65 -and $_ -le 90}
                    {
                        $Deciphered.Add([Char](($_ - 65 + $Filter[$FilterIndex % $Filter.Length]) % 26 + 65)) | Out-Null
                        $FilterIndex += 1
                    }
                    #Decipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122}
                    {
                        $Deciphered.Add([Char](($_ - 97 + $Filter[$FilterIndex % $Filter.Length]) % 26 + 97)) | Out-Null
                        $FilterIndex += 1
                    }
                    #Pass through symbols and numbers
                    Default { $Deciphered.Add($Character) | Out-Null }
                }
            }#Join the results of the decipher
            $Plaintext = $Deciphered -join ""
            #Check is spacing is used
            If ($Spacing -ge 1)
            {
                #Remove existing whitespaces
                $Plaintext = $Plaintext -replace '\s', ''
                #Split the plaintext into the desired spacing
                $Plaintext = ([RegEx]::Matches($Plaintext, ".{1,$Spacing}") | ForEach-Object { $_.Value }) -join ' '
            }
            $Result = [PSCustomObject]@{
                'Plaintext' = $Plaintext
                'Ciphertext' = $Message
                'Key' = $Key
            }
            $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Vigenere')
            #Add results of the decipher
            $DecipheredMessages.Add($Result) | Out-Null
        }
    }
    End
    {
        #Return the results
        Return $DecipheredMessages
    }
}