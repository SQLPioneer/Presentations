$EnvName = "aw_dev"

"Pres:\Helper.psm1" | Import-Module
Write-Host "Starting $EnvName" -BackgroundColor Blue
# $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml
$password = $mycred.GetNetworkCredential().Password

Get-Command -Module DBAChecks | OGV

get-dbccheck | ogv
Get-DbcConfig | ogv
GET-DbcconfigValue -Name app.sqlinstance
Set-DbcConfig -Name app.sqlinstance -Value localhost

Invoke-DbcCheck -AllChecks -PassThru | Update-DbcPowerBiDataSource 


Invoke-DbcCheck -SqlInstance localhost -Check Agent
Invoke-DbcCheck -SqlInstance localhost -Check Database 
Invoke-DbcCheck -SqlInstance localhost -Check Domain
Invoke-DbcCheck -SqlInstance localhost -Check HADR
Invoke-DbcCheck -SqlInstance localhost -Check Instance
Invoke-DbcCheck -SqlInstance localhost -Check LogShipping
Invoke-DbcCheck -SqlInstance localhost -Check MaintenanceSolution
Invoke-DbcCheck -SqlInstance localhost -Check Server


Invoke-DbcCheck -TestName SuspectPage, LastBackup -OutputFormat NUnitXml -OutputFile data:\tests.xml

