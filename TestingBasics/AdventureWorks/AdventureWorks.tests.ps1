$EnvName = "aw_dev"
"Pres:\Helper.psm1" | Import-Module
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa

"Pres:\TestingBasics\RunTests.psm1" | Import-Module -Force
Invoke-DatabaseTesting  `
    -Server $EnvName `
    -Database 'AdventureWorks' `
    -Credential $mycred `
    -TestDirectory 'Pres:\TestingBasics\AdventureWorks\'  

