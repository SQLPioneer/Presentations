
$HostName = "aw_Server"
$connectionProd = 'localhost,1402'
$result = docker start $HostName
if ($result -ne $HostName) {
    "Pres:\Helper.psm1" | Import-Module
    Write-Host "Starting $HostName" -BackgroundColor Blue
    Write-Host "Read password from secure file" -ForegroundColor Green
    $pwd = Get-SecurePassword -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key
    Write-Host "Build the PSCredential object for setting passwords" -ForegroundColor Green
    $mycred = New-Object System.Management.Automation.PSCredential("sa",$pwd)
    $password = $mycred.GetNetworkCredential().Password

    Write-Host "Create Production Container" -ForegroundColor Green
    docker run -d `
        -p 1402:1433 `
        --name $HostName `
        -e sa_password=$Password `
        -e ACCEPT_EULA=Y `
        -v C:/docker/Adv/data/:C:/data/ `
        -v C:/data/backup/:C:/backup/ `
        -v C:/data/Scripts/:C:/scripts/ `
        --hostname $HostName `
        -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `
        microsoft/mssql-server-windows-developer
}

Write-Progress -Activity "Waiting 30 seconds for server to start" -Status "Sleeping"  
Start-Sleep -Seconds 30
#$configPath = ".\$HostName.DbcConfig.json"
#Import-DbcConfig -Path $configPath
#Invoke-DbcCheck -Tag InstanceConnection -SqlInstance $connection -SqlCredential $mycred
Invoke-Sqlcmd -ServerInstance $connectionProd -Username sa -Password $password -Query "sp_dropserver @@servername;  
GO  
sp_addserver aw_server, local;  
GO  "
docker restart $HostName
Invoke-Sqlcmd -ServerInstance $connectionProd -Database 'AdventureWorks' -Username sa -Password $password -Query "select @@SERVERNAME, DB_NAME()"
