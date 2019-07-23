# Install-Module dbachecks
# Import-Module dbachecks

# Invoke-DbcCheck -SqlInstance $Servers SuspectPage, LastBackup -OutputFormat NUnitXml -OutputFile data:\tests.txt



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


Describe "a thing" {

    Context "thing is shiny" {
        It "is true" {
            $true | should be $true
        }
    }
}

Describe "Load-Config"{
    It "Password is not empty" {
        $config.Count | should be -gt 0
    }
}