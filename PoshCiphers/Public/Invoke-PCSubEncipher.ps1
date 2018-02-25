Function Invoke-PCSubEncipher
{
    <# 
        .Synopsis
        Enciphers plaintext message(s) with a substitution cipher.

        .Description
        Enciphers plaintext message(s) with a substitution cipher, only works with the English alphabet.

        .Parameter Plaintext
        The plaintext message(s) to be enciphered.

        .Parameter Substitution
        The substitution alphabet to use for enciphering. 
            Default value is a randomly generated alphabet.
        
        .Parameter Spacing
        The amount of characters to insert spaces between in the ciphertext.
            Default value is 0.
        
        .Parameter Strip
        Removes whitespaces from the plaintext message(s).

        .Example
        Invoke-PCSubEncipher -Plaintext "Example"

        PlainText         Ciphertext         Substitution
        ---------         ----------         ------------
        Example           Ixtvksi            TYNFIRMBHEGSVULKWQJDPACXO

        .Example
        Invoke-PCSubEncipher -Plaintext "Example With Spaces" -Substitution "TYNFIRMBHEGSVULKWQJDPACXO" -Strip

        PlainText                 Ciphertext                Substitution
        ---------                 ----------                ------------
        ExampleWithSpaces         IxtvksiChdbJktnij         TYNFIRMBHEGSVULKWQJDPACXO

        .Example
        Invoke-PCSubEncipher -Plaintext "Example With Spaces" -Substitution "TYNFIRMBHEGSVULKWQJDPACXO" -Spacing 4

        PlainText                   Ciphertext                    Substitution
        ---------                   ----------                    ------------
        Example With Spaces         Ixtv ksiC hdbJ ktni j         TYNFIRMBHEGSVULKWQJDPACXO

        .LINK
        https://github.com/stackcrash/PoshCiphers
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String[]] $Plaintext,
        [Parameter(Mandatory = $False, Position=1)]
        [String] $Substitution,
        [Parameter(Mandatory = $False, Position=2)]
        [String] $Spacing = 0,
        [Parameter(Mandatory = $False)]
        [Switch]$Strip
    )
    Begin
    {
        #Create an array list to store results in
        $EncipheredMessages = New-Object System.Collections.ArrayList
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
        Else
        {
            #Generate a random substitution alphabet
            $Substitution = @()
            While ($Substitution.ToCharArray().Count -lt 25)
            {
                $Letter = [Char]((Get-Random -Minimum 0 -Maximum 25) + 65)
                #If letter already in substitution alphabet gets a random new letter
                If ($Letter -notin $Substitution.ToCharArray())
                {
                    $Substitution += $Letter
                }
            }
        }
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
                    {$_ -ge 65 -and $_ -le 90} { 
                        $PlainIndex = $Alphabet.IndexOf([Char]$_)
                        $Enciphered.Add(($Substitution[$PlainIndex])) | Out-Null
                     }
                    #Encipher lowercase characters
                    {$_ -ge 97 -and $_ -le 122} {
                        $PlainIndex = $Alphabet.IndexOf([Char]($_ - 97 + 65))
                        $Enciphered.Add([Char](([Byte]$Substitution[$PlainIndex] -65 + 97))) | Out-Null
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
            $Result = [PSCustomObject]@{
                'Plaintext' = $Message
                'Ciphertext' = $Ciphertext
                'Substitution' = $Substitution -join ''
            }
            $Result.PSObject.TypeNames.Insert(0,'PoshCiphers.Substitution')
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