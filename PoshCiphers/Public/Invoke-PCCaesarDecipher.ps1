Function Invoke-PCCaesarDecipher
{
    <# 
        .Synopsis
        Deciphers message(s) that has been enciphered with a rotation based cipher.

        .Description
        Deciphers message(s) that has been enciphered with a rotation based cipher.

        .Parameter Ciphertext
        The enciphered message(s) to be deciphered.

        .Parameter Rotation
        The rotation to use for deciphering. 
            Default value is 13.
        
        .Parameter Strip
        Removes whitespaces from the ciphertext message(s).

        .Example
        Invoke-PCCaesarDecipher -Ciphertext "Rknzcyr" -Rotation 13

        Plaintext Ciphertext Rotation
        --------- ---------- --------
        Example   Rknzcyr          13

        .Example
        Invoke-PCCaesarDecipher -Ciphertext "Rknzcyr Jvgu Fcnprf" -Rotation 13 -Strip

        Plaintext         Ciphertext        Rotation
        ---------         ----------        --------
        ExampleWithSpaces RknzcyrJvguFcnprf       13

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
        [Int] $Rotation = 13,
        [Parameter()]
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
                    {$_ -ge 65 -and $_ -le 90} { $Deciphered.Add([Char]((Get-PCModulus -Dividend $($_ - 65 - $Rotation) -Divisor 26) + 65)) | Out-Null }
                    #Decipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122} { $Deciphered.Add([Char]((Get-PCModulus -Dividend $($_ - 97 - $Rotation) -Divisor 26) + 97)) | Out-Null }
                    #Pass through symbols and numbers
                    Default { $Deciphered.Add($Character) | Out-Null }
                }
            }
            #Add results of the decipher
            $DecipheredMessages.Add(([PSCustomObject]@{
                'Plaintext' = $Deciphered -join ""
                'Ciphertext' = $Message
                'Rotation' = $Rotation
            })) | Out-Null
        }
    }
    End
    {
        #Return the results
        Return $DecipheredMessages
    }
}