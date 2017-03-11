Function Invoke-PCVigenereEncipher
{
    <# 
        .Synopsis
        Enciphers plaintext message(s) with a Vigenere cipher.

        .Description
        Enciphers plaintext message(s) with a Vigenere cipher.

        .Parameter Plaintext
        The plaintext message(s) to be enciphered.

        .Parameter Key
        The key to use in the enciphering.
        Note: The key is case-insensitive.

        .Parameter Spacing
        The amount of characters to insert spaces between in the ciphertext.
            Default value is 0.
        
        .Parameter Strip
        Removes whitespaces from the plaintext message(s).

        .Example
        Invoke-PCVigenereEncipher -Plaintext "Example" -Key "password"

        Plaintext Ciphertext Key
        --------- ---------- ---
        Example   Txselzv    password

        .Example
        Invoke-PCVigenereEncipher -Plaintext "Example With Spaces" -Key "password" -Strip

        Plaintext         Ciphertext        Key
        ---------         ----------        ---
        Examplewithspaces TxselzvZxtzKlothh password

        .Example
        Invoke-PCVigenereEncipher -Plaintext "Example With Spaces" -Key "password" -Spacing 4

        Plaintext           Ciphertext            Key
        ---------           ----------            ---
        Example With Spaces Txse lzvZ xtzK loth h password

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Plaintext,
        [Parameter(Mandatory = $True, Position=1)]
        [String] $Key,
        [Parameter(Mandatory = $False, Position=2)]
        [String] $Spacing = 0,
        [Parameter()]
        [Switch]$Strip
    )
    Begin
    {
        #Create an array list to store results in
        $EncipheredMessages = New-Object System.Collections.ArrayList
    }
    Process
    {
        #Loop through each message
        ForEach ($Message in $Plaintext)
        {
            #Create an array list to store enciphered characters in
            $Enciphered = New-Object System.Collections.ArrayList
            #Get the Vigenere table for the key
            $Filter = Get-PCVigenereFilter -Key $Key
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
                    #Encipher uppercase characters
                    {$_ -ge 65 -and $_ -le 90}
                    {
                        $Enciphered.Add([Char](($_ - 65 + $Filter[$FilterIndex % $Filter.Length]) % 26 + 65)) | Out-Null
                        $FilterIndex += 1
                    }
                    #Encipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122}
                    {
                        $Enciphered.Add([Char](($_ - 97 + $Filter[$FilterIndex % $Filter.Length]) % 26 + 97)) | Out-Null
                        $FilterIndex += 1
                    }
                    #Pass through symbols and numbers
                    Default { $Enciphered.Add($Character) | Out-Null }
                }
            }
            #Join the results of the encipher
            $Ciphertext = $Enciphered -join ""
            #Check is spacing is used
            If ($Spacing -ge 1)
            {
                #Remove existing whitespaces
                $Ciphertext = $Ciphertext -replace '\s', ''
                #Split the ciphertext into the desired spacing
                $Ciphertext = ([RegEx]::Matches($Ciphertext, ".{1,$Spacing}") | ForEach-Object { $_.Value }) -join ' '
            }
            #Add results of the encipher
            $EncipheredMessages.Add(([PSCustomObject]@{
                'Plaintext' = $Message
                'Ciphertext' = $Ciphertext
                'Key' = $Key
            })) | Out-Null
        }
    }
    End
    {
        #Return the array of PowerShell objects
        Return $EncipheredMessages
    }
}