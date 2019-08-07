docker pull docs/docker.github.io
docker start docs
http://localhost:4000
docker stop docs

"Pres:\Helper.psm1" | Import-Module
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

# download SQL Server 2017 Developer Container
docker pull microsoft/mssql-server-windows-developer:2017-CU1

# Start the container mapping the port to 1401
# p Ports
# --name is container name
# -- hostname can be used by external source instead of the port
# -e 
docker run -d `
    -p 1402:1433 `
    --name sql2 `
    --hostname sql2 `
    -e sa_password=$Password `
    -e ACCEPT_EULA=Y `
    -v C:/data/backup/:C:/backup/ `
    -v C:/data/Scripts/:C:/scripts/ `
    -v C:/docker/Adv/data/:C:/data/ `
    -e attach_dbs="[{'dbName':'AdventureWorks','dbFiles':['C:\\data\\AdventureWorks2017.mdf','C:\\data\\AdventureWorks2017_log.ldf']}]" `
    microsoft/mssql-server-windows-developer

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

docker exec -it aw_preprod powershell

$password = $Config.password
docker run -d -p 1401:1433 --name sql2 -e sa_password="$password" -e ACCEPT_EULA=Y -v C:/data/:C:/data/ microsoft/mssql-server-windows-developer
docker stop sql2
docker rm sql2

# Run the container attaching database
docker run -p 1401:1433 --name FIFA -e sa_password=$password -e ACCEPT_EULA=Y -v C:/data/:C:/data/ -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\data\\FIFA.mdf','C:\\data\\data\\FIFA_log.ldf']}]" microsoft/mssql-server-windows-developer
# -a STDOUT microsoft/mssql-server-windows-developer

# Look at the databases on the server
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database master -Username sa -Password $password -Query  "SELECT * FROM master.sys.databases" | Select-Object -ExpandProperty name
# Look at the tables in a database
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password $password -Query  "SELECT * FROM INFORMATION_SCHEMA.tables" | Out-GridView

docker stop sql2
docker start sql2

reset FIFA
reset WWI







# Pull a small server for practice
docker pull mcr.microsoft.com/windows/nanoserver:1709


