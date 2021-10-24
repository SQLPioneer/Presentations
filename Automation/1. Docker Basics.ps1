https://docs.docker.com/engine/reference/commandline/docker/

"Pres:\Helper.psm1" | Import-Module
#$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml
$password = $mycred.GetNetworkCredential().Password

# download SQL Server 2019 Developer Container
docker pull mcr.microsoft.com/mssql/server:2019-latest
# download SQL Server 2017 Developer Container
docker pull mcr.microsoft.com/mssql/server:2017-latest


# Fields required to start docker container
# -p Ports
# -e environment variable for the sa password
# -e Environment variable for accepting the license agreement
# image name 
docker run `
    -p 1433:1433 `
    -e SA_PASSWORD=$password `
    -e ACCEPT_EULA=Y `
    mcr.microsoft.com/mssql/server:2019-latest

# Optional parameters used to start container
# --name is the container name
# --hostname is a network alias
# -v is volume path outside container:Inside container
# -e Environment variable that accepts a list of databases to attach upon startup
# --rm Remove container when stopped
docker run -d `
    -p 1433:1433 `
    --name aw_preprod `
    --hostname aw_preprod `
    -e SA_PASSWORD=$Password `
    -e ACCEPT_EULA=Y `
    -v aw_preprod_backup:/var/opt/mssql/backup `
    --rm `
    mcr.microsoft.com/mssql/server:2019-latest

docker exec -it aw_preprod mkdir /var/opt/mssql/backup
    
docker cp C:\data\Backup\WideWorldImporters-Full.bak aw_preprod:/var/opt/mssql/backup

Restore-DbaDatabase -SqlInstance localhost -SqlCredential $mycred -Path /var/opt/mssql/backup/WideWorldImporters-Full.bak -DatabaseName WWI

    -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\data\\AdventureWorks2017_log.ldf']}]" `

# connect to running container
docker exec -it aw_preprod powershell

function reset ($container) { 
    docker stop $Container
    docker rm $container
    switch ($container) {
        "Adv" {
            Remove-Item "C:\docker\$container\data\AdventureWorks2017.mdf"
            Remove-Item "C:\docker\$container\data\AdventureWorks2017_log.ldf"
        }
    }
}

reset sql2

Pres:\Automation\EnvCreation\CreateEnvironments.ps1
Pres:\Automation\EnvCreation\CreateDevImage.ps1
# Create container from existing image
docker run -d -p 1425:1433 --name aw_dev --hostname aw_dev aw_dev.image:demo.automation
# Remove Image
docker rmi aw_dev.image:demo.automation
