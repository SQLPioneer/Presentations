$EnvName = "aw_dev"
"Pres:\Helper.psm1" | Import-Module
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

# Install-Module dbachecks
# Import-Module dbachecks
# install-module Pester
import-module Pester

Describe "a thing" {
    Context "thing is shiny" {
        It "true is true" {
            $true | should be $true
        }
    }
}

Invoke-Sqlcmd -Server $EnvName -Username sa -Password $password `
-Query "SELECT name, cmptlevel, filename FROM master.sys.sysdatabases WHERE name = 'AdventureWorks'" `
| Out-GridView

$Database = "AdventureWorks"
Describe "Running SQL Tests on $EnvName for database $Database" {
  Context "Database $Database" {
    $results = Invoke-Sqlcmd -Server $EnvName -Database $Database -Username sa -Password $password `
        -Query "SELECT name, cmptlevel, filename FROM master.sys.sysdatabases WHERE name = 'AdventureWorks'"
    It "Does AdventureWorks exist" {
        @($results).name | Should -Be 'AdventureWorks' 
    }
    It "AdventureWorks Compatibility Level 14.0" {
        @($results).cmptlevel | Should -Be '140' 
    }
    It "AdventureWorks file location is c:\data\AdventureWorks2017.mdf" {
        @($results).filename | Should -Be 'c:\data\AdventureWorks2017.mdf' 
    }
  }
}

"Pres:\TestingBasics\RunTests.psm1" | Import-Module -Force
Invoke-DatabaseTesting  `
    -Server 'aw_dev' `
    -Database 'AdventureWorks' `
    -Credential $mycred `
    -TestDirectory 'Pres:\TestingBasics\AdventureWorks\'  `
    -Filter 'AdventureWorks database exists.1.sql'

Invoke-DatabaseTesting  `
    -Server 'aw_dev' `
    -Database 'AdventureWorks' `
    -Credential $mycred `
    -TestDirectory 'Pres:\TestingBasics\AdventureWorks\'


invoke-pester -Script "Pres:\TestingBasics\AdventureWorks" -OutputFile TestResults.xml -OutputFormat NUnitXml
