Import-Module dbatools

Get-SqlCredential -
Get-DbaRegisteredServer -SqlCredential 

$ViewName = "vname"
$ServerInstance = "localhost"
$DB Demo
# Write out the text of the view to a file
$Views = Get-DbaDbView -SqlInstance $ServerInstance -Database $DB -ExcludeSystemView
$View1 = $Views | where Name -eq "$ViewName" 
$View1.TextBody | Out-File -FilePath c:\temp\$ViewName.sql

New-DbaAgentJobStep -SqlInstance $ServerInstance -Job 'Adams Test Job' -StepId 1 -StepName "Run Something" -Subsystem "TransactSql" -Command "select @@Servername" -Database sfs
$adam = get-DbaAgentJobStep -SqlInstance $ServerInstance -Job 'Adams Test Job' 
$adam.DatabaseName demo
$adam.Alter()
$adam.DatabaseName  
Remove-DbaAgentJob -SqlInstance $ServerInstance -Job "Adams Test Job"

