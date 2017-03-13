Function Invoke-PCKasiskiExam
{
    <# 
        .Synopsis
        Performs Kasiski examination on supplied ciphertext and returns the factors.

        .Description
        Performs Kasiski examination on supplied ciphertext and returns the factors.

        .Parameter Ciphertext
        Ciphertext to examine.

        .Example
        Invoke-PCKasiskiExam -Ciphertext 'TpczwxviXzkxfitvgkwevvhtnitpwbetnvgbhlgixasxkjqhvitrxxdcfzjyagwcxygvcecnfmpkigvifgeklmgjxhvieztawv'
        2
        3
        6
        7
        14
        21
        42
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True, Position=0, ValueFromPipeline=$True)]
        [String] $Ciphertext
    )
    Begin
    {
        #Remove anything that is not a letter
        $Ciphertext = [Regex]::Replace($Ciphertext,'[^a-zA-Z]','').ToUpper()
        $Repeats = New-Object System.Collections.ArrayList
    }
    Process
    {
        $Series = New-Object System.Collections.ArrayList
        #Get all unique three letter words that repeat
        ForEach ($Index in 0..($Ciphertext.Length - 2))
        {
            $Letters = $Ciphertext[$Index..($Index + 2)] -join ''
            If ($Letters -notin $Series -and $Letters.Length -eq 3) { $Series.Add($Letters) | Out-Null }
        }
        #Loop through each set of letters
        ForEach ($Letters in $Series)
        {
            #Get all the matches of the letters
            $Matched = [Regex]::Matches($Ciphertext,$Letters)
            #If the letters repeated
            If ($Matched.Count -gt 1)
            {
                $Spaces = New-Object System.Collections.ArrayList
                $Factors = New-Object System.Collections.ArrayList
                #Gets the index of each repeat
                $Indexes = $Matched | Select-Object -ExpandProperty Index
                #Generates a negative version of the index for use later
                $NegList = $Indexes | ForEach-Object { -$_ }
                #Gets the spaces between repeats by adding the negative version to each index
                ForEach ($Index in $Indexes)
                {
                    ForEach ($Neg in $NegList)
                    {
                        #Only keeping positive results
                        If ($Index + $Neg -gt 0)
                        {
                            $Spaces.Add(($Index + $Neg)) | Out-Null
                        }
                    }
                }
                #Gets the factors for the spaces that are greater than 2
                ForEach ($Space in $Spaces)
                {
                    2..$Space | ForEach-Object {
                        If ($Space % $_ -eq 0)
                        {
                            $Factors.Add($_) | Out-Null
                        }
                    }
                }
                $Result = [PSCustomObject]@{
                    'Letters' = $Letters
                    'Spaces' = $Spaces
                    'Factors' = $Factors
                }
                $Repeats.Add($Result) | Out-Null
            }
        }
    }
    End
    {
        #Counts how many sets of factors are generated
        $Count = $Repeats | Measure-Object | Select-Object -ExpandProperty Count
        If ($Count)
        {
            If ($Count -gt 1)
            {
                #Returns all factors that repeated more than once
                Return $Repeats.Factors | Group-Object |
                                Where-Object {$_.Count -gt 1} |
                                Select-Object -ExpandProperty Name
            }
            ElseIf ($Count -eq 1)
            {
                #Returns the entire set of factors
                Return $Repeats.Factors | Group-Object |
                                Select-Object -ExpandProperty Name
            }
        }
        Else { Return $Null }
    }
}