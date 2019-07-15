docker pull docs/docker.github.io
docker start docs
http://localhost:4000
docker stop docs

"Pres:\SecurityHacks.psm1" | Import-Module
function Load-Config {
    #     retrieve password from encrypted file
    $pwd = Get-SecurePassword -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key
    # build the PSCredential object
    $mycred = New-Object System.Management.Automation.PSCredential("sa",$pwd)
    # Create hash table to hold my configuration parameters 
    $Config = @{
        "ServerInstance"="localhost,1401"
        "Database"="demo"
        "Username"=$user
        "Password"=$mycred.GetNetworkCredential().Password
        "ProdBackup"="c:\data\Backup\Prod"

    }
}


# download SQL Server 2017 Developer Container
docker pull microsoft/mssql-server-windows-developer:2017-CU1

# Start the container mapping the port to 1401
docker run -d -p 1401:1433 --name sql2 -e sa_password=$Config.password -e ACCEPT_EULA=Y -v C:/data/:C:/data/ microsoft/mssql-server-windows-developer
docker stop sql2
docker rm sql2

# Run the container attaching database
docker run -p 1401:1433 --name sql2 -e sa_password=$Config.password -e ACCEPT_EULA=Y -v C:/data/:C:/data/ -e attach_dbs="[{'dbName':'FIFA','dbFiles':['C:\\data\\FIFA.mdf','C:\\data\\FIFA_log.ldf']}]" microsoft/mssql-server-windows-developer
# -a STDOUT microsoft/mssql-server-windows-developer

# Look at the databases on the server
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database master -Username sa -Password $Config.password -Query  "SELECT * FROM master.sys.databases" | Out-GridView

# Look at the tables in a database
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password $Config.password -Query  "SELECT * FROM INFORMATION_SCHEMA.tables" | Out-GridView

docker stop sql2
docker start sql2

docker stop sql2
docker rm sql2








# Pull a small server for practice
docker pull mcr.microsoft.com/windows/nanoserver:1709


