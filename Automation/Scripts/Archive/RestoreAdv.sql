USE [master]
EXEC xp_cmdshell 'dir c:\backup'
EXEC xp_cmdshell 'dir c:\data'

RESTORE DATABASE [AdventureWorks2017] 
	FROM  DISK = N'C:\Backup\AdventureWorks2017.bak' WITH  FILE = 1
	,  MOVE N'AdventureWorks2017' TO N'C:\data\AdventureWorks2017.mdf'
	,  MOVE N'AdventureWorks2017_log' TO N'C:\data\AdventureWorks2017_log.ldf'
	,  NOUNLOAD,  REPLACE,  STATS = 5

/*
RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1
	,  MOVE N'WWI_Primary' TO N'C:\data\WideWorldImporters.mdf'
	,  MOVE N'WWI_UserData' TO N'C:\data\WideWorldImporters_UserData.ndf'
	,  MOVE N'WWI_Log' TO N'C:\data\WideWorldImporters.ldf'
	,  MOVE N'WWI_InMemory_Data_1' 
	   TO N'C:\data\WideWorldImporters_InMemory_Data_1'
	,  NOUNLOAD,  REPLACE,  STATS = 5



RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\data\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1
	,  MOVE N'WWI_Primary' TO N'C:\data\data\WideWorldImporters.mdf'
	,  MOVE N'WWI_UserData' TO N'C:\data\data\WideWorldImporters_UserData.ndf'
	,  MOVE N'WWI_Log' TO N'C:\data\data\WideWorldImporters.ldf'
	,  MOVE N'WWI_InMemory_Data_1' TO N'C:\data\data\WideWorldImporters_InMemory_Data_1'
	,  NOUNLOAD,  REPLACE,  STATS = 5

USE [master]
RESTORE DATABASE [AdventureWorks2017] 
	FROM  DISK = N'C:\data\Backup\AdventureWorks2017.bak' WITH  FILE = 1
	,  MOVE N'AdventureWorks2017' TO N'C:\data\Data\AdventureWorks2017.mdf'
	,  MOVE N'AdventureWorks2017_log' TO N'C:\data\Data\AdventureWorks2017_log.ldf'
	,  NOUNLOAD,  REPLACE,  STATS = 5

*/


