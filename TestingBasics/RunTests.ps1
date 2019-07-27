[cmdletbinding()]
param( 
  <# 
    .Synopsis 
    This script will run all of the .sql scripts in a folder. 
    .Description 
    It is important to note that the name of the .sql file must take the form of name.1.sql
    For example "Test is database exists.1.sql" or "Test if view is unique by primary key.0.sql"
    .PARAMETER Server
    Specifies the name of the SQL Server instance to run the tests against.
    .PARAMETER Database
    Specifies the name of the database to connect to.
    .PARAMETER TestDirectory
    Enter the fully qualified path of the directory that all of the tests reside in.
    
  #>
  [Parameter(Mandatory=$true)] [string]$Server, 
  [Parameter(Mandatory=$true)] [string]$Database, 
  [Parameter(Mandatory=$true)] [string]$TestDirectory,
  [Parameter(Mandatory=$false)] [pscredential]$Credential
)

if (!$Credential) {"Credential is null"}
Describe "Running SQL Tests on $Server for database $Database" {
  Context "$TestDirectory" {
    foreach ($file in Get-ChildItem -path $TestDirectory -Filter "*.sql" | Sort-Object) {
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
