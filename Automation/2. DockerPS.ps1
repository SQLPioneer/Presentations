
$mycred = Import-Clixml -Path Data:\mycred.xml
$password = $mycred.GetNetworkCredential().Password

# Manage Volumn Data by creating a helper container I'm using a Powershell container
# This container stops as soon as it runs if you don't include -it
docker run -v aw_preprod_backup:/backup --name helper -it mcr.microsoft.com/powershell
Install-Module DBATools
$mycred = Get-Credential -UserName sa -Message "Enter sa Password"

# Starting the "helper" container that is stopped 
docker start -i helper

docker cp .\WorldWideImporters.bak helper:/backup
docker cp  helper:/backup/WorldWideImporters.bak  .


Get-DbaDatabase -SqlInstance 172.17.0.2 -SqlCredential $mycred

Get-DbaDatabase -SqlInstance localhost -SqlCredential $mycred
