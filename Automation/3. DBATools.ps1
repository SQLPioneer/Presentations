https://dbatools.io/commands/

Import-Module dbatools
"Pres:\Helper.psm1" | Import-Module

Get-Command -Module dbatools | Out-GridView

#$SqlCred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml

$ServerInstance = "localhost"
#Get-DbaDatabase -SqlCredential $SqlCred -SqlInstance $ServerInstance | ogv
Get-DbaDatabase -SqlInstance $ServerInstance | ogv

Backup-DbaDatabase -SqlInstance $ServerInstance -Path "c:\data\backup\"  -Type Full
Backup-DbaDatabase -SqlInstance $ServerInstance -Path "c:\data\backup\"  -Type Diff

# Write out the text of the view to a file
$DB = "AdventureWorks2017"
$Tables = Get-DbaDbTable -SqlInstance $ServerInstance -Database $DB
$Tables | ogv

$Tables | Get-Member | ogv
$Tables | where name -eq 'Customer' | select Columns | get-member | ogv


$Views = Get-DbaDbView -SqlInstance $ServerInstance -Database $DB -ExcludeSystemView
$Views | ogv
$ViewName = "vVendorWithAddresses"
$View1 = $Views | where Name -eq "$ViewName" 
$View1 | Get-Member | ogv
$View1.TextBody | Out-File -FilePath c:\temp\$ViewName.sql
edit c:\temp\$ViewName.sql

New-DbaAgentJob -SqlInstance $ServerInstance -Job 'Adams Test Job'
New-DbaAgentJobStep -SqlInstance $ServerInstance -Job 'Adams Test Job' -StepId 1 -StepName "Run Something" -Subsystem "TransactSql" -Command "select @@Servername" -Database master
$adam = get-DbaAgentJobStep -SqlInstance $ServerInstance -Job 'Adams Test Job' 
$adam.DatabaseName  
$adam.DatabaseName = "demo"
$adam.DatabaseName  
Remove-DbaAgentJob -SqlInstance $ServerInstance -Job "Adams Test Job"

