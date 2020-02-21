https://docs.docker.com/engine/reference/commandline/docker/

"Pres:\Helper.psm1" | Import-Module
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

# download SQL Server 2017 Developer Container
docker pull microsoft/mssql-server-windows-developer:2017-CU1
docker pull microsoft/mssql-server-windows-developer

# Fields required to start docker container
# -p Ports
# -e environment variable for the sa password
# -e Environment variable for accepting the license agreement
# image name 
docker run -d `
    -p 1402:1433 `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    microsoft/mssql-server-windows-developer

# Optional parameters used to start container
# --name is the container name
# --hostname is a network alias
# -v is volume path outside container:Inside container
# -e Environment variable that accepts a list of databases to attach upon startup
# --rm Remove container when stopped
docker run -d `
    -p 1402:1433 `
    --name aw_preprod `
    --hostname aw_preprod `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    -v C:/docker/Adv/data/:C:/data/ `
    -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `
    --rm
    microsoft/mssql-server-windows-developer

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
