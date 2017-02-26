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
The longer the ciphertext the more likely it is to return an accurate result like below.
```powershell
Get-RotBruteForce -Ciphertext "Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr"

Plaintext                                     Ciphertext                                    Rotation           Entroy
---------                                     ----------                                    --------           ------
This is an example that should be long enough Drsc sc kx ohkwzvo drkd cryevn lo vyxq oxyeqr       10 109.798786942039
```
When the ciphertext is too short it might be benefitial to return multiple results.
```powershell
Get-RotBruteForce -Ciphertext "Ohkwzvo" -Return 6

Plaintext Ciphertext Rotation           Entroy
--------- ---------- --------           ------
Atwilha   Ohkwzvo          14 19.8330281092882
Lehtwsl   Ohkwzvo           3 20.1951620075682
Hadpsoh   Ohkwzvo           7 20.5561918374628
Tmpbeat   Ohkwzvo          21 21.2523902999804
Wpsehdw   Ohkwzvo          18 22.2203513815375
Example   Ohkwzvo          10 24.0221984573182
```
Bigrams can be used and are more accurate than single letter frequency calculations
```powershell
Get-RotBruteForce -Ciphertext "Qjmybxq" -Bigrams -Return 4

Plaintext Ciphertext Rotation          Entropy
--------- ---------- --------          -------
Atwilha   Qjmybxq          16 15.0861096952459
Tmpbeat   Qjmybxq          23 16.1689118339204
Hadpsoh   Qjmybxq           9 16.3222746155573
Example   Qjmybxq          12  16.535234171974
```

## Planned
- Add support for brute forcing Vigenere ciphers.