$HostName = "aw_preprod"
"Pres:\Helper.psm1" | Import-Module
# $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml

Backup-DbaDatabase -SqlInstance $HostName -SqlCredential $mycred 

Invoke-DbcCheck -SqlInstance aw_preprod -Tags LastFullBackup -Database AdventureWorks,FIFA -SqlCredential $mycred 

