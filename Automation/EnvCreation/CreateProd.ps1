$Prod = "aw_server"
$HostName = $Prod
$result = docker start $HostName
if ($result -ne $HostName) {
    "Pres:\Helper.psm1" | Import-Module
    Write-Host "Starting $HostName" -BackgroundColor Blue
    $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
    $password = $mycred.GetNetworkCredential().Password

    Write-Host "Create Production Container" -ForegroundColor Green
    docker run -d `
        -p 1402:1433 `
        --name $HostName `
        --hostname $HostName `
        -e sa_password=$Password `
        -e ACCEPT_EULA=Y `
        -v C:/data/backup/:C:/backup/ `
        -v C:/data/Scripts/:C:/scripts/ `
        -v C:/docker/Adv/data/:C:/data/ `
        -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `
        microsoft/mssql-server-windows-developer
}

Write-Progress -Activity "Waiting 30 seconds for server to start" -Status "Sleeping"  
Start-Sleep -Seconds 30
$configPath = ".\$HostName.DbcConfig.json"
Import-DbcConfig -Path $configPath
Invoke-DbcCheck -Tag InstanceConnection -SqlInstance $HostName -SqlCredential $mycred
Invoke-DbcCheck -SqlInstance aw_server -Tags DatabaseExists -Database AdventureWorks -SqlCredential $mycred
