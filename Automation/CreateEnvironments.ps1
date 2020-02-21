"Pres:\SecurityHacks.psm1" | Import-Module
Import-Module dbatools
Write-Host "Start Script" -BackgroundColor Blue
Write-Host "Read password from secure file" -ForegroundColor Green
$pwd = Get-SecurePassword -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key
Write-Host "Build the PSCredential object for setting passwords" -ForegroundColor Green
$mycred = New-Object System.Management.Automation.PSCredential("sa",$pwd)
$password = $mycred.GetNetworkCredential().Password

Write-Host "Create Production Container" -ForegroundColor Green
docker run -d `
    -p 1402:1433 `
    --name Adv `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/docker/Adv/data/:C:/data/ `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    --hostname AWServer `
    -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `
    microsoft/mssql-server-windows-developer

Start-Sleep -Seconds 40
Write-Host "Backup Production Database AdventureWorks" -ForegroundColor Green
Backup-DbaDatabase -SqlInstance "localhost,1402" -SqlCredential $mycred -Database AdventureWorks -Path c:\backup\ -BackupFileName dbname.bak -ReplaceInName
# Invoke-Sqlcmd -ServerInstance "localhost,1402" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | select -ExpandProperty name

Write-Host "Create Preproduction Container" -ForegroundColor Green
docker run -d `
    -p 1403:1433 `
    --name PreProd `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/docker/PreProd/data/:C:/data/ `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    --hostname AWPreProd `
    -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\FIFA.mdf','C:\\data\\FIFA_log.ldf']}]" `
    microsoft/mssql-server-windows-developer

Start-Sleep -Seconds 40
Write-Host "Restore AdventureWorks from Production" -ForegroundColor Green
Restore-DbaDatabase `
    -SqlInstance "localhost,1403" `
    --hostname qa11 `
    -SqlCredential $mycred `
    -Path c:\backup\AdventureWorks.bak `
    -DatabaseName AdventureWorks `
    -DestinationDataDirectory c:\data\ `
    -DestinationLogDirectory c:\data
Write-Host "Attached Databases" -ForegroundColor Green
Invoke-Sqlcmd -ServerInstance "localhost,1403" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name

docker run -d `
    -p 1410:1433 `
    --name qa_container `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    microsoft/mssql-server-windows-developer

Write-Host "There is no external Data directory mapped to this container" -ForegroundColor Red
Write-Host "Create a Data directory inside this container" -ForegroundColor Green
docker exec -it qa_container mkdir data
Start-Sleep -Seconds 40
Restore-DbaDatabase `
    -SqlInstance "localhost,1410" `
    -SqlCredential $mycred `
    -Path c:\backup\AdventureWorks.bak `
    -DatabaseName AdventureWorks `
    -DestinationDataDirectory c:\data\ `
    -DestinationLogDirectory c:\data
Invoke-Sqlcmd -ServerInstance "localhost,1410" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name


# ToDo: Create script for replacing data and use it here
Invoke-Sqlcmd -ServerInstance "localhost,1410" -Database master -Username sa -Password $password -InputFile C:\data\Scripts\cmd.sql

############################
#
Write-Host "Stop the container and then create an image from that container"
#
#
##############################
docker stop qa_container
docker commit qa_container qa_image:latest
# remove container to save space
docker rm qa_container

docker run -d `
    -p 1411:1433 `
    --name qa11 `
    --hostname qa11 `
    qa_image:latest
Invoke-Sqlcmd -ServerInstance "qa11" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name
Invoke-Sqlcmd -ServerInstance "qa11" -Database master -Username sa -Password $password -InputFile "C:\data\Scripts\FixSidOwner.sql"
Invoke-Sqlcmd -ServerInstance "qa11" -Database master -Username sa -Password $password -InputFile "C:\data\Scripts\SetClrEnabled.sql"
Invoke-Sqlcmd -ServerInstance "qa11" -Database master -Username sa -Password $password -InputFile "C:\data\Scripts\tSQLt.class.sql"

docker run -d `
    -p 1412:1433 `
    --name qa12 `
    --hostname qa12 `
    qa_image:latest
Invoke-Sqlcmd -ServerInstance "localhost,1412" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name

# ToDo: Create script for replacing data and use it here
Invoke-Sqlcmd -ServerInstance "localhost,1411" -Database master -Username sa -Password $password -InputFile C:\data\Scripts\cmd.sql
docker stop qa12
docker commit qa12 dev_image:latest

docker run -d `
    -p 1412:1433 `
    --name dev `
    --hostname DevAdam `
    dev_image:latest

Invoke-Sqlcmd -ServerInstance "localhost,1402" -Database master -Username sa -Password $password -InputFile C:\data\Scripts\RestoreAdv.sql
Invoke-Sqlcmd -ServerInstance "localhost,1405" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | select -ExpandProperty name


# docker exec -ti Adv powershell
# Backup-DbaDatabase -SqlInstance "localhost,1402" -SqlCredential $cre -Database FIFA -Path c:\backup -IgnoreFileChecks