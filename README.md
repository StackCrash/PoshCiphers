# PoshCiphers
Powershell module for enciphering and deciphering common Caesar (Rotation) ciphers.

## Install
* Clone the repo
* Import the module
```powershell
Import-Module C:\Path\To\Cloned\Location\PoshCiphers\PoshCiphers\PoshCiphers.psm1
```

## Usage
### Encipher
#### Caesar (Rotation)
```powershell
Get-RotEncipher -Plaintext "Example" -Rotation 13

Plaintext Ciphertext Rotation
--------- ---------- --------
Example   Rknzcyr          13
```

#### Vigenere
```powershell
Get-VigEncipher -Plaintext "Example" -Key "password"

Plaintext Ciphertext Key
--------- ---------- ---
Example   Txselzv    password
```

### Decipher
#### Caesar (Rotation)
```powershell
Get-RotDecipher -Ciphertext "Rknzcyr" -Rotation 13

Plaintext Ciphertext Rotation
--------- ---------- --------
Example   Rknzcyr          13
```

#### Vigenere
```powershell
Get-VigDecipher -Ciphertext "Txselzv" -Key "password"

Plaintext Ciphertext Key
--------- ---------- ---
Example   Txselzv    password
```

## Bruteforcing
### Caesar
The longer the ciphertext the more likely it is to return an accurate result like below. The lower the entropy the more likely the match is correct.
```powershell
Get-RotBruteForce -Ciphertext "Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr"

Plaintext                                     Ciphertext                                    Rotation           Entropy
---------                                     ----------                                    --------           ------
This is an example that should be long enough Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr       10 109.798786942039
```
When the ciphertext is too short it might be benefitial to return multiple results.
```powershell
Get-RotBruteForce -Ciphertext "Ohkwzvo" -Return 6

Plaintext Ciphertext Rotation           Entropy
--------- ---------- --------           ------
Atwilha   Ohkwzvo          14 19.8330281092882
Lehtwsl   Ohkwzvo           3 20.1951620075682
Hadpsoh   Ohkwzvo           7 20.5561918374628
Tmpbeat   Ohkwzvo          21 21.2523902999804
Wpsehdw   Ohkwzvo          18 22.2203513815375
Example   Ohkwzvo          10 24.0221984573182
```
Bigrams can be used and are more accurate than single letter frequency calculations. Below is an example of both and how bigrams result in better accuracy.
```powershell
Get-RotBruteForce -Ciphertext "Kx ohkwzvo" -Return 4

Plaintext  Ciphertext Rotation          Entropy
---------  ---------- --------          -------
Hu lehtwsl Kx ohkwzvo        3 26.5836919196097
Pc tmpbeat Kx ohkwzvo       21 28.7825588445318
Sf wpsehdw Kx ohkwzvo       18 28.7847612412839
An example Kx ohkwzvo       10  29.223042839157

Get-RotBruteForce -Ciphertext "Kx ohkwzvo" -Bigrams

Plaintext  Ciphertext Rotation          Entropy
---------  ---------- --------          -------
An example Kx ohkwzvo       10 18.3733998951538
```

## Planned
- Add support for brute forcing Vigenere ciphers.