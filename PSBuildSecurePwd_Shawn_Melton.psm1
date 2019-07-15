function New-KeyFile {
<# 
.SYNOPSIS 
Creates a new key and saves it to a file.

.DESCRIPTION 
This script provides the ability to easily create a "key" file.

THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.PARAMETER KeyFile
Full path to file that the "key" will be saved.

.PARAMETER KeySize
Desired key size, requires value to be 16, 24 or 32.

.PARAMETER Force
Specifying will force the provided KeyFile to be overwritten if it already exist.

.NOTES 
Author: Shawn Melton (@wsmelton), http://blog.wsmelton.com

.EXAMPLE   
New-KeyFile -KeyFile C:\MyKey.key -KeySize 16

Description
Generates a 16 byte[] key and saves it to C:\MyKey.key.
#>	
    [cmdletbinding()]
    param(
        [string]$KeyFile,
        [ValidateSet(16,24,32)]
        [int]$KeySize,
        [switch]$Force
    )

    if ( (Test-Path $KeyFile) -and (-not $Force) ) {
        throw "File path provided already exist, use [-Force] if you wish to overwrite the file."
    }

    $genKey = New-Object Byte[] $KeySize
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($genKey)
    $genKey | out-file $KeyFile
}

function New-PasswordFile {
<# 
.SYNOPSIS 
Creates a new password file.

.DESCRIPTION 
Creates a password file with the encrypted value based on the Key provided.

THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.PARAMETER PwdFile
Full path to file that the "password" will be saved.

.PARAMETER Password
Password value to be encrypted, if no value is passed in will prompt for a SecureString pasword using Read-Host

.PARAMETER Key
Key to be used for encrypting the password.

.PARAMETER Force
Specifying will force the provided PwdFile to be overwritten if it already exist.

.NOTES 
Author: Shawn Melton (@wsmelton), http://blog.wsmelton.com

.EXAMPLE   
New-PasswordFile -PwdFile C:\MyPassword.txt -Key (Get-Content C:\MyKey.key)

Description
Encryptes the provided password with the key found in C:\MyKey.key, and saves to C:\MyPassword.txt

.EXAMPLE   
$pwd = Get-Credential
New-PasswordFile -PwdFile C:\MyPassword.txt -Password ($pwd.GetNetworkCredential().SecurePassword) -Key (Get-Content C:\MyKey.key)

Description
Captures the password provided in Get-Credential.
Encrypts the password provided in $pwd with the key found in C:\MyKey.key, and saves to C:\MyPassword.txt
#>	
    [cmdletbinding()]
    param(
        [string]$PwdFile,
        [SecureString]$Password = (Read-Host -Prompt "Enter the password to add to the file" -AsSecureString),
        [Byte[]]$Key,
        [switch]$Force
    )

    if ( (Test-Path $PwdFile) -and (-not $Force) ) {
        throw "File path provided already exist, use [-Force] if you wish to overwrite the file."
    }

    ConvertFrom-SecureString -SecureString $Password -Key $Key | Out-File $PwdFile
}

function Get-SecurePassword {
<# 
.SYNOPSIS 
Pulls in the password as a SecureString.

.DESCRIPTION 
Pulls the encrypted password utilizing the key file provided to output a SecureString.

THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.PARAMETER PwdFile
Full path to file that the "passowrd" is saved.

.PARAMETER KeyFile
Full path to file that the "key" is saved.

.NOTES 
Author: Shawn Melton (@wsmelton), http://blog.wsmelton.com

.EXAMPLE   
Get-SecurePassword -PwdFile C:\MyPassword.txt -KeyFile C:\MyKey.key

Description
Retrieves the password found in C:\MyPassword.txt and decrypts it using the key found in C:\MyKey.key. 
Outputs the SecureString object to be used in a PSCredential object.
#>
    [cmdletbinding()]
    param(
        [string]$PwdFile,
        [string]$KeyFile
    )

    if ( !(Test-Path $PwdFile) ) {
        throw "Password File provided does not exist."
    }
    if ( !(Test-Path $KeyFile) ) {
        throw "KeyFile was not found."
    }

    $keyValue = Get-Content $KeyFile
    Get-Content $PwdFile | ConvertTo-SecureString -Key $keyValue
}
