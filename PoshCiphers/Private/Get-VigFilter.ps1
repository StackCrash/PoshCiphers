Function Get-VigFilter 
{
    <# 
        .Synopsis
        Returns an array of numbers representing the vigenere key.

        .Description
        Returns an array of numbers representing the vigenere key.

        .Parameter Key
        The key to use.

        .Example
        Get-VigFilter -Key "password"
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String] $Key
    )
    Begin
    {
        $KeyArray = New-Object System.Collections.ArrayList
    }
    Process
    {
        ForEach ($Character in $Key.ToCharArray())
        {
            Switch ([Byte]$Character)
            {
                #Uppercase characters
                {$_ -ge 65 -and $_ -le 90} { $KeyArray.Add((($_ - 65) % 32)) | Out-Null }
                #Lowercase characters
                {$_ -ge 97 -and $_ -le 122} { $KeyArray.Add((($_ - 97) % 32)) | Out-Null }
                #Ignore symbols and numbers
                Default { Out-Null }
            }
        }
    }
    End
    {
        Return $KeyArray
    }
}