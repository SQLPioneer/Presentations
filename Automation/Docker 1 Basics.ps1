docker pull docs/docker.github.io
docker start docs
http://localhost:4000
docker stop docs

# download SQL Server 2017 Developer Container
docker pull microsoft/mssql-server-windows-developer:2017-CU1

# Start the container mapping the port to 1401
docker run -d -p 1401:1433 --name sql2 -e sa_password=IloveDoing1 -e ACCEPT_EULA=Y -v C:/data/:C:/data/ microsoft/mssql-server-windows-developer
docker stop sql2
docker rm sql2

# Run the container attaching database
docker run -p 1401:1433 --name sql2 -e sa_password=IloveDoing1 -e ACCEPT_EULA=Y -v C:/data/:C:/data/ -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\FIFA.mdf','C:\\data\\FIFA_log.ldf']}]" microsoft/mssql-server-windows-developer
# -a STDOUT microsoft/mssql-server-windows-developer

# Look at the databases on the server
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database master -Username sa -Password IloveDoing1 -Query  "SELECT * FROM master.sys.databases" | Out-GridView

# Look at the tables in a database
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  "SELECT * FROM INFORMATION_SCHEMA.tables" | Out-GridView

# Clear Players table so we can populate it
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  "TRUNCATE TABLE Players"

$FirstName = 'Adam'
$Lastname = 'Anderson'
$SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $FirstName, $Lastname
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  $SQLQuery

$Players = @{"FirstName"="Jennifer";"Lastname"="Anderson"}
$SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $Players.FirstName, $Players.Lastname
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  $SQLQuery

$Players = @(
    @{"FirstName"="Jessica";"Lastname"="Smith"};
    @{"FirstName"="John";"Lastname"="Doe"}
    )

foreach($Player in $Players){
    $SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $Player.FirstName, $Player.Lastname
    Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  $SQLQuery
}

$Players = Import-Csv -Path "C:\git\Docker\Scripts\FullName.csv"
foreach($Player in $Players){
    $SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $Player.FirstName, $Player.Lastname
    Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  $SQLQuery
}

docker stop sql2
docker start sql2
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password IloveDoing1 -Query  "SELECT * FROM Players" | Format-Table -Property FirstName, Lastname

docker stop sql2
docker rm sql2








# Pull a small server for practice
docker pull mcr.microsoft.com/windows/nanoserver:1709


