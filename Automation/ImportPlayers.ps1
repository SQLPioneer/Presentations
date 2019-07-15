# This is an example of an import data script for importing data
# Call file and pass in variables 
<#
    .SYNOPSIS 
    Imports a CSV file into the Players table
    
    .DESCRIPTION 
    Imports data into the Players table in the demo database
    
    THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.
    
    .PARAMETER Path
    Path to the CSV file

    .EXAMPLE   
    .\ImportPlayers -Path "C:\git\Docker\Scripts\FullName.csv"

#>
param(
    [string]$Path
    ,[boolean]$Truncate = $false
)

# Import password from secure file
$user = "sa"
$pwd = Get-SecurePassword -PwdFile c:\data\MyPwd.txt -KeyFile c:\data\MyKey.key
 
# build the PSCredential object
# This can be used for windows authentication or to decrypt the password to send into a connection string
$mycred = New-Object System.Management.Automation.PSCredential("sa",$pwd)
$SQLParms = @{
    "ServerInstance"="localhost,1401"
    "Database"="FIFA"
    "Username"=$user
    "Password"=$mycred.GetNetworkCredential().Password
}

Function Invoke-Query ($Config, $Query) {
    Invoke-Sqlcmd `
        -ServerInstance $Config.ServerInstance `
        -Database $Config.Database `
        -Username $Config.Username `
        -Password $Config.Password `
        -Query  $Query
}
Function Add-Player ($FirstName, $Lastname){
    $SQLQuery = "INSERT INTO Players VALUES('{0}','{1}');" -f $FirstName, $Lastname
    Invoke-Query -Config  $SQLParms -Query $SQLQuery
}

Function Import-Players ($Path){
    $Players = Import-Csv -Path $Path
    # If names inclued ' in their names then double '' them for import
    foreach($Player in $Players){
        $Player.FirstName = $Player.FirstName -replace "'","''"
        $Player.Lastname = $Player.Lastname -replace "'","''"
    }

    foreach($Player in $Players){
        Add-Player $Player.Firstname $Player.LastName
    }
}


if ($Truncate) { 
    $SQLQuery = "TRUNCATE TABLE Players"
    Invoke-Query -Config  $SQLParms -Query $SQLQuery
}
Import-Players $Path

