Function Get-Entropy
{
    <# 
        .Synopsis
        Returns the entropy for the supplied text compared to English letter frequancies.

        .Description
        Returns the entropy for the supplied text compared to English letter frequancies.

        .Parameter Text
        Text to generate entropy based on.

        .Example
        Get-Entropy "Example"
        24.0221984573182
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String] $Text
    )
    Begin
    {
        [Double]$Entropy = 0
        [Double[]]$Freq = 0.08167,0.01492,0.02782,0.04253,0.12702,0.02228,0.02015,
        0.06094,0.06966,0.00153,0.00772,0.04025,0.02406,0.06749,0.07507,0.01929,
        0.00095,0.05987,0.06327,0.09056,0.02758,0.00978,0.02360,0.00150,0.01974,
        0.00074
    }
    Process
    {
        #Remove anything that is not a letter
        $Text = [Regex]::Replace($Text,'[^a-zA-Z]','').ToUpper()
        #Loop though each character in the text
        ForEach ($Character in $Text.ToCharArray())
        {
            #Convert the character to ASCII code
            Switch ([Byte]$Character)
            {
                #Calculate entropy of uppercase characters
                {$_ -ge 65 -and $_ -le 90} { $Entropy += (-[Math]::Log($Freq[$_ - 65])) }
                #Calculate entropy of lowercase characters
                {$_ -ge 97 -and $_ -le 122} { $Entropy += (-[Math]::Log($Freq[$_ - 97])) }
                #Ignore anything thats not a letter
                Default { Out-Null }
            }
        }
    }
    End
    {
        Return $Entropy
    }
}