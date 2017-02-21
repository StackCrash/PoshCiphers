Function Get-RotEncipher
{
    <# 
        .Synopsis
        Enciphers plaintext message(s) with a rotation based cipher.

        .Description
        Enciphers plaintext message(s) with a rotation based cipher.

        .Parameter Plaintext
        The plaintext message(s) to be enciphered.

        .Parameter Rotation
        The rotation to use for enciphering. 
            Default value is 13.
        
        .Parameter Strip
        Removes whitespaces from the plaintext message(s).

        .Example
        Get-RotEncipher -Plaintext "Example" -Rotation 13

        Plaintext Ciphertext Rotation
        --------- ---------- --------
        Example   Rknzcyr          13

        .Example
        Get-RotEncipher -Plaintext "Example With Spaces" -Rotation 13 -Strip

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
        [String[]] $Plaintext,
        [Parameter(Mandatory = $False, Position=1)]
        [Int] $Rotation = 13,
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
                    {$_ -ge 65 -and $_ -le 90} { $Enciphered.Add([Char]((Get-Modulus -Dividend $($_ - 65 + $Rotation) -Divisor 26) + 65)) | Out-Null }
                    #Decipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122} { $Enciphered.Add([Char]((Get-Modulus -Dividend $($_ - 97 + $Rotation) -Divisor 26) + 97)) | Out-Null }
                    #Pass through symbols and numbers
                    Default { $Enciphered.Add($Character) | Out-Null }
                }
            }
            #Add results of the encipher
            $EncipheredMessages.Add(([PSCustomObject]@{
                'Plaintext' = $Message
                'Ciphertext' = $Enciphered -join ""
                'Rotation' = $Rotation
            })) | Out-Null
        }
    }
    End
    {
        #Return the array of PowerShell objects
        Return $EncipheredMessages
    }
}