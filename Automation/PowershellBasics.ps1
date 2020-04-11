# https://powershellexplained.com/2017-01-13-powershell-variable-substitution-in-strings/?utm_source=blog&utm_medium=blog&utm_content=popref


Set-Alias -Name Edit -Value "notepad++.exe"
Edit $profile

Get-Command -Module dbatools -all | ogv
Get-Command -Module dbatools -all | Get-Member
Get-Command -Module dbatools -all | select name, CommandType, Verb, Noun | ogv

New-PSDrive -name Pres -PSProvider FileSystem -Root "C:\git\GitHub\Presentations"
New-PSDrive -name Data -PSProvider FileSystem -Root "C:\Data"
Set-Location Pres:

#     Import module used to create a security key and password file.
"Pres:\Helper.psm1" | Import-Module

#     (1) Create our key file
# New-KeyFile -KeyFile Data:\MyKey.key -KeySize 16
#     (2) Create our password file
# New-PasswordFile -PwdFile Data:\MyPwd.txt -Key (Get-Content Data:\MyKey.key)
# $mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$mycred = Import-Clixml -Path Data:\mycred.xml
$password = $mycred.GetNetworkCredential().Password
 
# Create variables to hole my SQLCMD parameters
$ServerInstance="localhost,1401"
$Database="FIFA"
$Username=$user

# Create hash table to hold my configuration parameters 
$Config = @{
    "ServerInstance"="localhost,1401"
    "Database"="FIFA"
    "Username"=$user
    "Password"=$password
    "Query"="SELECT @@ServerName AS ServerName"
}

# Use the Invoke-Sqlcmd to query a table in the database
# Shows the command with all parameters filled out manually
Invoke-Sqlcmd -ServerInstance @Config
Invoke-Sqlcmd -ServerInstance "localhost,1401" -Database FIFA -Username sa -Password ******** -Query  "SELECT * FROM Players"
# Show the command using the first set of variables
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $Username -Password $Password -Query "SELECT * FROM Players"
# Show the command using the hash table variables
Invoke-Sqlcmd -ServerInstance $Config.ServerInstance -Database $Config.Database -Username $Config.Username -Password $Config.Password -Query "SELECT * FROM Players"

# Create a function to Run a query with less typing
Function Invoke-Query ($Query) {
    Invoke-Sqlcmd `
        -ServerInstance $Config.ServerInstance `
        -Database $Config.Database `
        -Username $Config.Username `
        -Password $Config.Password `
        -Query  $Query
}
Invoke-Query "SELECT * FROM Players"

Function Get-Players {
    $SelectQuery = "SELECT * FROM Players"
    Invoke-Query $SelectQuery
}
Get-Players

# Set basic Variables to import into the Players table
$FirstName = 'Adam'
$Lastname = 'Anderson'

# Token substitution {0}
$SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $FirstName, $Lastname
$SQLQuery
Invoke-Query $SQLQuery
Get-Players

Function Add-Player ($FirstName, $Lastname){
    $SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $FirstName, $Lastname
    Invoke-Query $SQLQuery
}
Add-Player $Firstname $LastName
Get-Players

# Hashtable 
$Players = @{"FirstName"="Jennifer";"Lastname"="Anderson"}
$SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $Players.FirstName, $Players.Lastname
Invoke-Query $SQLQuery
Get-Players

# Create a Hashtable of values to insert
$Players = @(
    @{"FirstName"="Jessica";"Lastname"="Smith"};
    @{"FirstName"="John";"Lastname"="Doe"}
)
# Loop through the hashtable and insert the values
foreach($Player in $Players){
    $SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $Player.FirstName, $Player.Lastname
    Invoke-Query $SQLQuery
}
Get-Players

$Players = Import-Csv -Path "C:\git\Docker\Scripts\FullName.csv"
foreach($Player in $Players){
    Add-Player $Player.Firstname $Player.LastName
}

Get-Players | Out-GridView


