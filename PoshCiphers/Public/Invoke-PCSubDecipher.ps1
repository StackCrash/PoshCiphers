Function Invoke-PCSubDecipher
{
    <# 
        .Synopsis
        Deciphers ciphertext message(s) with a substitution cipher.

        .Description
        Deciphers ciphertext message(s) with a substitution cipher, only works with the English alphabet.

        .Parameter Ciphertext
        The ciphertext message(s) to be deciphered.

        .Parameter Substitution
        The substitution alphabet to use for deciphering. 
            Default value is a randomly generated alphabet.
        
        .Parameter Spacing
        The amount of characters to insert spaces between in the ciphertext.
            Default value is 0.
        
        .Parameter Strip
        Removes whitespaces from the ciphertext message(s).

        .Example
        Invoke-PCSubDecipher -Ciphertext "Ixtvksi" -Substitution "TYNFIRMBHEGSVULKWQJDPACXO"

        PlainText         Ciphertext         Substitution
        ---------         ----------         ------------
        Example           Ixtvksi            TYNFIRMBHEGSVULKWQJDPACXO

        .Example
        Invoke-PCSubDecipher -Ciphertext "Ixtvksi Chdb Jktnij" -Substitution "TYNFIRMBHEGSVULKWQJDPACXO" -Strip

        PlainText                 Ciphertext                Substitution
        ---------                 ----------                ------------
        ExampleWithSpaces         IxtvksiChdbJktnij         TYNFIRMBHEGSVULKWQJDPACXO

        .Example
        Invoke-PCSubDecipher -Ciphertext "Ixtvksi Chdb Jktnij" -Substitution "TYNFIRMBHEGSVULKWQJDPACXO" -Spacing 4

        PlainText                     Ciphertext                  Substitution
        ---------                     ----------                  ------------
        Exam pleW ithS pace s         Ixtvksi Chdb Jktnij         TYNFIRMBHEGSVULKWQJDPACXO

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Ciphertext,
        [Parameter(Mandatory = $True, Position=1)]
        [String] $Substitution,
        [Parameter(Mandatory = $False, Position=2)]
        [String] $Spacing = 0,
        [Parameter(Mandatory = $False)]
        [Switch]$Strip
    )
    Begin
    {
        #Create an array list to store results in
        $DecipheredMessages = New-Object System.Collections.ArrayList
        #Normal alphabet for referencing
        $Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
        #Error checking on substitution alphabet
        If ($Substitution)
        {
            If (-Not [Regex]::Match($Substitution,'^[aA-zZ]+$'))
            {
                Write-Error "The Substitution contains non-alphabetic characters."
            }
            #Make sure the substitution alphabet is unqique
            If (($Substitution.ToUpper().ToCharArray() | Group-Object | Select-Object -ExpandProperty Count) -gt 1)
            {
                Write-Error "The Substitution must be a unique ordering of the English alphabet."
            }
            #Make sure the substitution alphabet is the correct length
            If ($Substitution.ToUpper().ToCharArray().Count -ne 26)
            {
                Write-Error "The Substitution does not contain 26 unique letters."
            }
        }
    }
    Process
    {
        #Loop through each message
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
                    {$_ -ge 65 -and $_ -le 90} { 
                        $CipherIndex = $Substitution.IndexOf([Char]$_)
                        $Deciphered.Add(($Alphabet[$CipherIndex])) | Out-Null
                     }
                    #Decipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122} {
                        $CipherIndex = $Substitution.IndexOf([Char]($_ - 97 + 65))
                        $Deciphered.Add([Char](([Byte]$Alphabet[$CipherIndex] -65 + 97))) | Out-Null
                    }
                    #Pass through symbols and numbers
                    Default { $Deciphered.Add($Character) | Out-Null }
                }
            }
            #Join the results of the decipher
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
                'Substitution' = $Substitution -join ''
            }
            $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Substitution')
            #Add results of the decipher
            $DecipheredMessages.Add($Result) | Out-Null
        }
    }
    End
    {
        #Return the array of PowerShell objects
        Return $DecipheredMessages
    }
}