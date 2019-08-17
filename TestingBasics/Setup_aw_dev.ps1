$EnvName = "aw_dev"
"Pres:\Helper.psm1" | Import-Module
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

# Pres:\Automation\EnvCreation\CreateDevImage.ps1
docker run -d -p 1425:1433 --name aw_dev --hostname aw_dev aw_dev.image:demo.automation

