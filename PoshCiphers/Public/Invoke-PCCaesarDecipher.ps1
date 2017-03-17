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
                'Rotation' = $Rotation
            }
            $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Caesar')
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