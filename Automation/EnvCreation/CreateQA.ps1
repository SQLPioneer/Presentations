# $Prod = "aw_server"
$EnvName = "aw_qa"
$Connect = "localhost,1410"
$result = docker start $EnvName
if ($result -ne $EnvName) {
    "Pres:\Helper.psm1" | Import-Module
    Write-Host "Starting $EnvName" -BackgroundColor Blue
#    $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
    $mycred = Import-Clixml -Path Data:\mycred.xml
    $password = $mycred.GetNetworkCredential().Password

    Write-Host "Create Test Container" -ForegroundColor Green
    docker run -d `
        -p 1410:1433 `
        --name $EnvName `
        --hostname $EnvName `
        -e sa_password=$Password `
        -e ACCEPT_EULA=Y `
        -v C:/data/backup/:C:/backup/ `
        -v C:/data/Scripts/:C:/scripts/ `
        microsoft/mssql-server-windows-developer

    Write-Host "There is no external Data directory mapped to this container" -ForegroundColor Green
    Write-Host "Create a Data directory inside this container" -ForegroundColor Green
    docker exec -it $EnvName powershell mkdir data

    Write-Progress -Activity "Waiting 20 seconds for server to start" -Status "Sleeping"  
    Start-Sleep -Seconds 20
    Write-Host "Restore AdventureWorks from Production" -ForegroundColor Green
    Restore-DbaDatabase `
        -SqlInstance $Connect `
        -SqlCredential $mycred `
        -Path c:\backup\AdventureWorks.bak `
        -DatabaseName AdventureWorks `
        -DestinationDataDirectory c:\data\ `
        -DestinationLogDirectory c:\data

    Invoke-Sqlcmd -ServerInstance $Connect -Database master -Username sa -Password $password -InputFile C:\data\Scripts\cmd.sql

    Docker stop $EnvName
    Docker commit $EnvName "$EnvName.image:demo.automation"
}
