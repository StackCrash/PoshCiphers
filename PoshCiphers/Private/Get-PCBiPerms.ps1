Function Get-PCBiPerms
{
    <# 
        .Synopsis
        Returns an array list of bigram permutations.

        .Description
        Returns an array list of bigram permutations.

        .Example
        Get-PCBiPerms
    #>
    Param
    ()
    Begin
    {
        $Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
        $AlphaLen = 0..($Alphabet.Length - 1)
    }
    Process
    {
        $Perms = New-Object System.Collections.ArrayList
        ForEach ($First in $AlphaLen)
        {
            ForEach ($Second in $AlphaLen)
            {
                $Perms.Add(($Alphabet[$First] + $Alphabet[$Second])) | Out-Null
            }
        }
    }
    End
    {
        #Keeps only the unique permuations
        #$Perms = $Perms | Sort-Object -Unique
        #Returns the array list of bigram permutations
        Return $Perms 
    }
}