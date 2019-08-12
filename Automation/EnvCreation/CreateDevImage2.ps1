".\CreateDevImage2.ps1" | Import-Module -Force
$EnvName = "aw_dev"
"Pres:\Helper.psm1" | Import-Module
Write-Host "Starting $EnvName" -BackgroundColor Blue
$mycred = Get-PSCredential -PwdFile Data:\MyPwd.txt -KeyFile Data:\MyKey.key -User sa
$password = $mycred.GetNetworkCredential().Password

# $result = docker start $ContainerName
$result = Start-DockerContainer -con $EnvName
if ($result -ne $EnvName) {
    Run-DockerImage `
        -ContainerPort 1433 `
        -ExternalPort 1420 `
        -Containername "aw_dev" `
        -hostname "aw_dev" `
        -Password $password
}


