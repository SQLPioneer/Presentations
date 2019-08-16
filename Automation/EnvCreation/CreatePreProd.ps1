$Prod = "aw_server"
$HostName = "aw_preprod"

"Pres:\Helper.psm1" | Import-Module
Write-Host "$HostName" -BackgroundColor Blue
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

Write-Host "Create Preproduction Container" -ForegroundColor Green
docker run -d `
    -p 1403:1433 `
    --name $HostName `
    --hostname $HostName `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    -v C:/docker/PreProd/data/:C:/data/ `
    -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\FIFA.mdf','C:\\data\\FIFA_log.ldf']}]" `
    microsoft/mssql-server-windows-developer
#        -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\FIFA.mdf','C:\\data\\FIFA_log.ldf']},{'dbName':'AdventureWorks2017','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `

Write-Host "Backup Production Database AdventureWorks" -ForegroundColor Green
Backup-DbaDatabase `
    -SqlInstance $Prod `
    -SqlCredential $mycred `
    -Database AdventureWorks `
    -Path c:\backup\ `
    -BackupFileName dbname.bak `
    -ReplaceInName

# Invoke-Sqlcmd -ServerInstance "localhost,1402" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | select -ExpandProperty name
docker exec -it $HostName powershell del c:\data\AdventureWorks2017.mdf
docker exec -it $HostName powershell del c:\data\AdventureWorks2017_log.ldf
Write-Progress -Activity "Waiting 20 seconds for server to start" -Status "Sleeping"  
Start-Sleep -Seconds 20
Write-Host "Restore AdventureWorks from Production" -ForegroundColor Green
Restore-DbaDatabase `
    -SqlInstance $HostName `
    -SqlCredential $mycred `
    -Path c:\backup\AdventureWorks.bak `
    -DatabaseName AdventureWorks `
    -DestinationDataDirectory c:\data\ `
    -DestinationLogDirectory c:\data
    
# Write-Host "Attached" -ForegroundColor Green
# Get-DbaDatabase -SqlInstance $HostName -ExcludeSystem -SqlCredential $mycred | select Name
# Invoke-Sqlcmd -ServerInstance $HostName -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name
# Invoke-DbcCheck -SqlInstance $HostName -SqlCredential $mycred -Tag InstanceConnection 
# Invoke-DbcCheck -SqlInstance $HostName -SqlCredential $mycred -Tags DatabaseExists -Database AdventureWorks,FIFA
# Invoke-DbcCheck -SqlInstance $HostName -SqlCredential $mycred -Tags Database -Database AdventureWorks,FIFA -ExcludeCheck Duplicateindex, RecoveryModel, LastDiffBackup, ValidDatabaseOwner,InvalidDatabaseOwner,LastGoodCheckDb, LastLogBackup
# Invoke-DbcCheck -SqlInstance $HostName -SqlCredential $mycred -Tags Database -ExcludeCheck Duplicateindex, RecoveryModel, LastDiffBackup, ValidDatabaseOwner,InvalidDatabaseOwner,LastGoodCheckDb, LastLogBackup
$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="InstanceConnection" 
}
Invoke-DbcCheck @Check -PassThru | Update-DbcPowerBiDataSource -Append
$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="DatabaseExists" 
    "Database"="AdventureWorks,FIFA"
}
Invoke-DbcCheck @Check -PassThru | Update-DbcPowerBiDataSource -Append
$Check = @{
    "SqlInstance"=$HostName 
    "SqlCredential"=$mycred 
    "Tags"="Database" 
    "ExcludeCheck"="Duplicateindex, RecoveryModel, LastDiffBackup, ValidDatabaseOwner,InvalidDatabaseOwner,LastGoodCheckDb, LastLogBackup"
}

Invoke-DbcCheck @Check -PassThru | Update-DbcPowerBiDataSource -Append

