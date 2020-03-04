$EnvName = "aw_dev"
"Pres:\Helper.psm1" | Import-Module
# $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml
$password = $mycred.GetNetworkCredential().Password

# Pres:\Automation\EnvCreation\CreateDevImage.ps1
docker run -d -p 1425:1433 --name aw_dev --hostname aw_dev aw_dev.image:demo.automation

$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="InstanceConnection" 
}
Invoke-DbcCheck @Check -PassThru | Update-DbcPowerBiDataSource
$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="DatabaseExists" 
}
Invoke-DbcCheck @Check -Database AdventureWorks,FIFA -PassThru | Update-DbcPowerBiDataSource -Append
$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="Database" 
    "ExcludeCheck"="Duplicateindex, RecoveryModel, LastDiffBackup, ValidDatabaseOwner,InvalidDatabaseOwner,LastGoodCheckDb, LastLogBackup"
}

Invoke-DbcCheck @Check -PassThru | Update-DbcPowerBiDataSource -Append

