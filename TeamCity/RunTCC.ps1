docker run -it --name teamcity-server-instance
    -v C:\TeamCity\Data:C:/ProgramData/JetBrains/TeamCity
    -v C:\TeamCity\Logs:C:/TeamCity/logs
    -p 8111:8111
    jetbrains/teamcity-server

docker run -it -e SERVER_URL="<url>"
    -v C:\TeamCity\BuildAgent\conf:C:/BuildAgent/conf
    -e AGENT_NAME="TeamCity_Agent_1"
    jetbrains/teamcity-agent
