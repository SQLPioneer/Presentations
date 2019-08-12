$EnvName = "aw_dev"

"Pres:\Helper.psm1" | Import-Module
Write-Host "Starting $EnvName" -BackgroundColor Blue
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -InputFile "C:\data\Scripts\RunAllTests.sql" | Select-Object -ExpandProperty xml* | out-file c:\temp\results.xml
$tResults = Invoke-Sqlcmd -ServerInstance $EnvName -Database AdventureWorks -Username sa -Password $password -Query "SELECT * FROM tSQLt.TestResult;"
foreach ($result in $tResults) {
    $class = $result.Class
    $TestCase = $result.TestCase
    $msg = $result.Msg
    describe "test Class $class" {
    it "$testcase" {
      $result.msg | Should -Be ''
    }
  }
}
