# $Prod = "aw_server"
$EnvName = "aw_dev"

"Pres:\Helper.psm1" | Import-Module
Write-Host "Starting $EnvName" -BackgroundColor Blue
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

$result = docker start $EnvName
if ($result -ne $EnvName) {
    Write-Host "Create $Envname Container" -ForegroundColor Green
    docker run -d `
        -p 1420:1433 `
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
        -SqlInstance $EnvName `
        -SqlCredential $mycred `
        -Path c:\backup\AdventureWorks.bak `
        -DatabaseName AdventureWorks `
        -DestinationDataDirectory c:\data\ `
        -DestinationLogDirectory c:\data

    Invoke-Sqlcmd -ServerInstance $EnvName -Database master -Username sa -Password $password -InputFile C:\data\Scripts\cmd.sql
    Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -InputFile "C:\data\Scripts\FixSidOwner.sql"
    Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -InputFile "C:\data\Scripts\SetClrEnabled.sql"
    Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -InputFile "C:\data\Scripts\tSQLt.class.sql"
    
    Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -InputFile "C:\data\Scripts\RunAllTests.sql" | Select-Object -ExpandProperty xml* | out-file c:\data\results.xml
#    $result[0] | out-file C:\temp\results.xml

    Docker stop $EnvName
    Docker commit $EnvName "$EnvName.image:demo.automation"
}
