
function Start-DockerContainer ([string]$ContainerName) {
    docker start $ContainerName
}
function Start-DockerContainer ([string]$ContainerName) {
    docker stop $ContainerName
}
function Remove-DockerContainer ([string]$ContainerName) {
    docker rm $ContainerName
}
function Remove-DockerImage ([string]$ImageName) {
    docker rmi $ImageName
}
function Create-DockerImageFromContainer ([string]$ContainerName,[string]$ImageName) {
    Docker commit $ContainerName "$ImageName"
}

function Get-DockerContainerList () {
    docker ps
}

function Run-DockerImage ([int]$ExternalPort, [string]$Containername, [string]$hostname, [string]$Password) {
    docker run -d `
        -p $ExternalPort:1433 `
        --name $Containername `
        --hostname $Containername `
        -e sa_password=$Password `
        -e ACCEPT_EULA=Y `
        -v C:/data/backup/:C:/backup/ `
        -v C:/data/Scripts/:C:/scripts/ `
        microsoft/mssql-server-windows-developer

}
