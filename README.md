# PoshCiphers
Powershell module for enciphering and deciphering common Caesar (Rotation) ciphers.

## Install
* Clone the repo
* Import the module
```powershell
Import-Module C:\Path\To\Cloned\Location\PoshCiphers\PoshCiphers\PoshCiphers.psd1
```

## Usage
### Encipher
#### Caesar (Rotation)
```powershell
Invoke-PCCaesarEncipher -Plaintext "Example" -Rotation 13

Plaintext Ciphertext Rotation
--------- ---------- --------
Example   Rknzcyr          13
```

#### Vigenere
```powershell
Invoke-PCVigenereEncipher -Plaintext "Example" -Key "password"

Plaintext Ciphertext Key
--------- ---------- ---
Example   Txselzv    password
```

### Decipher
#### Caesar (Rotation)
```powershell
Invoke-PCCaesarDecipher -Ciphertext "Rknzcyr" -Rotation 13

Plaintext Ciphertext Rotation
--------- ---------- --------
Example   Rknzcyr          13
```

#### Vigenere
```powershell
Invoke-PCVigenereDecipher -Ciphertext "Txselzv" -Key "password"

Plaintext Ciphertext Key
--------- ---------- ---
Example   Txselzv    password
```

## Bruteforcing
### Caesar
The longer the ciphertext the more likely it is to return an accurate result like below. The lower the entropy the more likely the match is correct.
```powershell
Invoke-PCBruteForceCaesar -Ciphertext "Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr"

Plaintext                                     Ciphertext                                    Rotation           Entropy
---------                                     ----------                                    --------           ------
This is an example that should be long enough Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr       10 109.798786942039
```
When the ciphertext is too short it might be benefitial to return multiple results.
```powershell
Invoke-PCBruteForceCaesar -Ciphertext "Ohkwzvo" -Return 6

Plaintext Ciphertext Rotation           Entropy
--------- ---------- --------           ------
Atwilha   Ohkwzvo          14 19.8330281092882
Lehtwsl   Ohkwzvo           3 20.1951620075682
Hadpsoh   Ohkwzvo           7 20.5561918374628
Tmpbeat   Ohkwzvo          21 21.2523902999804
Wpsehdw   Ohkwzvo          18 22.2203513815375
Example   Ohkwzvo          10 24.0221984573182
```

### Vigenere
As with Caesar the longer the ciphertext the more likely it is to return and accurate results. Additionally, the maximum key length also plays into the more accuracy of results.
```powershell
Invoke-PCBruteForceVigenere -Ciphertext 'Zls tnsogs wuv sebborj pwvy fkxkvkr lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh sapq st dgrqmbu nevtwekwy mg skxzif' -Return 2

PlainText                                Ciphertext                               Key                           Entropy
---------                                ----------                               ---                           -------
The cibmue lor nanaind liet oilwken      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORFRCMOLGEFEOBGE   210.614486327131
greudom and inthitest ant for the heist  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
hull of cankind inthitest is retter      sapq st dgrqmbu nevtwekwy mg skxzif
The choice for mankind lies between      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORGE               216.636909401074
freedom and happiness and for the great  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
bulk of mankind happiness is better      sapq st dgrqmbu nevtwekwy mg skxzif
```
When lowering the max key length it can eliminate inaccurate results that occur when the key length tested is significantly longer than the actual key.
```powershell
Invoke-PCBruteForceVigenere -Ciphertext 'Zls tnsogs wuv sebborj pwvy fkxkvkr lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh sapq st dgrqmbu nevtwekwy mg skxzif' -MaxKeyLength 10

PlainText                                Ciphertext                               Key                           Entropy
---------                                ----------                               ---                           -------
The choice for mankind lies between      Zls tnsogs wuv sebborj pwvy fkxkvkr      GEORGE               216.636909401074
freedom and happiness and for the great  lvsvjss ebu nevtwekwy ebu lsx xvv mvkeh
bulk of mankind happiness is better      sapq st dgrqmbu nevtwekwy mg skxzif
```
## Planned
- Increase accuracy of vigenere brute force