

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

Load-Config
$Exists = Test-Path -Path $ProdBackup
if (-not $Exists) {
#if ($Exists) {
    New-Item -ItemType Directory -Path $ProdBackup
}

Backup-DbaDatabase -SqlInstance $config.ServerInstance -Database $config.Database -Path $config.ProdBackup
Invoke-Sqlcmd -ServerInstance $config.ServerInstance -Query 'SELECT NAME FROM master.sys.databases'
Restore-DbaDatabase -SqlInstance $config.ServerInstance -DatabaseName demo_Prod -Path $config.ProdBackup -WithReplace -DestinationFileSuffix _Prod
Invoke-Sqlcmd -ServerInstance $config.ServerInstance -Query 'SELECT NAME FROM master.sys.databases'

