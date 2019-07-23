-- ALTER AUTHORIZATION ON DATABASE::[AdventureWorks] TO [sa]

DECLARE @Command VARCHAR(MAX) = 'ALTER AUTHORIZATION ON DATABASE::[AdventureWorks] TO 
[AdventureWorks_log]' 

SELECT @Command = REPLACE(REPLACE(@Command 
            , 'AdventureWorks', SD.Name)
            , 'AdventureWorks_log', SL.Name)
-- SELECT *
FROM master..sysdatabases SD 
JOIN master..syslogins SL ON  SD.SID = SL.SID
WHERE  SD.Name = DB_NAME()

PRINT @Command
EXEC(@Command)
