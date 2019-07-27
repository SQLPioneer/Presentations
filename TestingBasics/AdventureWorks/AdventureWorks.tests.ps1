
New-PSDrive -name Pres -PSProvider FileSystem -Root "C:\git\GitHub\Presentations"
New-PSDrive -name Data -PSProvider FileSystem -Root "C:\Data"
# Set-Location Pres:
# $Pas=@{"PwdFile"="Data:\MyPwd.txt";"KeyFile"="Data:\MyKey.key"}
$Pas=@{"PwdFile"="c:\data\MyPwd.txt";"KeyFile"="c:\data\MyKey.key"}
Test-Path $Pas.PwdFile

"Pres:\SecurityHacks.psm1" | Import-Module
# $pwd = Get-SecurePassword -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key
$pwd = Get-SecurePassword @Pas
$Credential = New-Object System.Management.Automation.PSCredential("sa",$pwd)

$parameters = @{
    "Server"="qa12"
    "database"="AdventureWorks"
    "TestDirectory"="Pres:\TestingBasics\AdventureWorks"
}
Pres:\TestingBasics\RunTests.ps1 @parameters -Credential $Credential

