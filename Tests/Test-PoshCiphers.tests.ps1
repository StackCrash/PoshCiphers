$ModulePath = "$PSScriptRoot\..\PoshCiphers\PoshCiphers.psd1"
Import-Module $ModulePath -Force

Describe "testing PoshCiphers" {
    InModuleScope PoshCiphers {
        Context "Get-PCBigramEntropy" {
            It "Returns a double for bigram entropy." {
                $Command = Get-PCBigramEntropy -Plaintext "Example"
                $Command | Should BeOfType Double
            }
        }

        Context "Get-PCBigramSquare" {
            It "Returns an array of bigrams." {
                $Command = Get-PCBigramSquare
                $Command | Should BeOfType Array
            }
        }

        Context "Get-PCModulus" {
            It "Returns the correct modulus." {
                $Command = Get-PCModulus -Dividend 65 -Divisor 26
                $Command | Should Be 13
            }
        }

        Context "Get-PCVigenereFilter" {
            It "Returns an array for the Vigenere filter." {
                $Command = Get-PCVigenereFilter -Key "Password"
                $Expected = 15,0,18,18,22,14,17,3
                ,$Command | Should Be ($Expected)
            }
        }

        Context "Invoke-PCBruteForceKey" {
            It "Returns the correct key from ciphertext." {
                $Command = Invoke-PCBruteForceKey -Ciphertext 'TpczwxviXzkxfitvgkwevvhtnitpwbetnvgbhlgixasxkjqhvitrxxdcfzjyagwcxygvcecnfmpkigvifgeklmgjxhvieztawv' -KeyLength 6
                $Command | Should Be "SECRET"
            }
        }

        Context "Invoke-PCKasiskiExam" {
            It "Returns the correct custom object." {
                $Command = Invoke-PCKasiskiExam -Ciphertext "TpczwxviXzkxfitvgkwevvhtnitpwbetnvgbhlgixasxkjqhvitrxxdcfzjyagwcxygvcecnfmpkigvifgeklmgjxhvieztawv"
                $Command | Should Be 13
            }
        }
    }
}