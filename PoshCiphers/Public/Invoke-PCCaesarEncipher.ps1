Function Invoke-PCCaesarEncipher
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
        
        .Parameter Spacing
        The amount of characters to insert spaces between in the ciphertext.
            Default value is 0.
        
        .Parameter Strip
        Removes whitespaces from the plaintext message(s).

        .Example
        Invoke-PCCaesarEncipher -Plaintext "Example" -Rotation 13

        Plaintext Ciphertext Rotation
        --------- ---------- --------
        Example   Rknzcyr          13

        .Example
        Invoke-PCCaesarEncipher -Plaintext "Example With Spaces" -Rotation 13 -Strip

        Plaintext         Ciphertext        Rotation
        ---------         ----------        --------
        ExampleWithSpaces RknzcyrJvguFcnprf       13

        .Example
        Invoke-PCCaesarEncipher -Plaintext "Example With Spaces" -Rotation 13 -Spacing 4

        Plaintext         Ciphertext              Rotation
        ---------         ----------              --------
        Example With Spaces Rknz cyrJ vguF cnpr f       13

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Plaintext,
        [Parameter(Mandatory = $False, Position=1)]
        [ValidateRange(1,25)]
        [Int] $Rotation = 13,
        [Parameter(Mandatory = $False, Position=2)]
        [String] $Spacing = 0,
        [Parameter(Mandatory = $False)]
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
                    #Encipher uppercase characters
                    {$_ -ge 65 -and $_ -le 90} { $Enciphered.Add([Char]((Get-PCModulus -Dividend $($_ - 65 + $Rotation) -Divisor 26) + 65)) | Out-Null }
                    #Encipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122} { $Enciphered.Add([Char]((Get-PCModulus -Dividend $($_ - 97 + $Rotation) -Divisor 26) + 97)) | Out-Null }
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
            $Result = [PSCustomObject]@{
                'Plaintext' = $Message
                'Ciphertext' = $Ciphertext
                'Rotation' = $Rotation
            }
            $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Caesar')
            #Add results of the encipher
            $EncipheredMessages.Add($Result) | Out-Null
        }
    }
    End
    {
        #Return the array of PowerShell objects
        Return $EncipheredMessages
    }
}