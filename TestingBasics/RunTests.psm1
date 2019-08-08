function Invoke-DatabaseTesting {
<# 
  .SYNOPSIS 
  This script will run all of the .sql scripts in a folder. 
  .DESCRIPTION 
  Database testing function used to run sql scripts and compare the row counts to the expected count specified in the name of the file.
  .NOTES
  It is important to note that the name of the .sql file must take the form of name.1.sql
  For example "Test if database exists.1.sql" or "Test if view is unique by primary key.0.sql"
  .PARAMETER Server
  Specifies the name of the SQL Server instance to run the tests against.
  .PARAMETER Database
  Specifies the name of the database to connect to.
  .PARAMETER TestDirectory
  Enter the fully qualified path of the directory that all of the tests reside in.
  .PARAMETER Credential
  Pass in a PSCredential object that will be used to connect to SQL Server. 
  If no credential object is provided then windows authentication is used

  .PARAMETER Filter
  Run all of the file in a folder that match the filter for Get-ChildItem

  .EXAMPLE
  Invoke-DatabaseTesting -Server Name -Database DBname -Test -$TestDirectory "."
  .EXAMPLE
  Invoke-DatabaseTesting -Server Name -Database DBname -Credential (GET-Credential) -$TestDirectory "."
  .EXAMPLE
  Invoke-DatabaseTesting -Server Name -Database DBname -Credential (GET-Credential) -$TestDirectory "." -Filter "*.sql"
  
#>
  param( 
    [cmdletbinding()]
    [Parameter(Mandatory=$true)] [string]$Server, 
    [Parameter(Mandatory=$true)] [string]$Database, 
    [Parameter(Mandatory=$false)] [pscredential]$Credential,
    [Parameter(Mandatory=$true)] [string]$TestDirectory,
    [Parameter(Mandatory=$false)] [string]$Filter = "*.sql"
  )

  if (!$Credential) {"Credential is null"}
  Describe "Running SQL Tests on $Server for database $Database" {
    Context "$TestDirectory" {
      foreach ($file in Get-ChildItem -path $TestDirectory -Filter $Filter | Sort-Object) {
        $TestName = $file.name.split(".")[0];
        [int32]$RowCount = $file.name.split(".")[1];
          $TestQuery = Get-Content $TestDirectory\$file -Raw
          if (!$Credential) {
            $results = Invoke-Sqlcmd -Server $Server -Database $Database -Query $TestQuery
          } else {
            $results = Invoke-Sqlcmd -Server $Server -Database $Database -Query $TestQuery -Username $Credential.GetNetworkCredential().UserName -Password $Credential.GetNetworkCredential().password
          }
          $TestName
          @($results).Count
          It "$TestName" {
            @($results).Count | Should be $RowCount
          }
        }
    }
  }
}