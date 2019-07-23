USE [master]
RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\data\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1
	,  MOVE N'WWI_Primary' TO N'C:\data\Data\WideWorldImporters.mdf'
	,  MOVE N'WWI_UserData' TO N'C:\data\Data\WideWorldImporters_UserData.ndf'
	,  MOVE N'WWI_Log' TO N'C:\data\Data\WideWorldImporters.ldf'
	,  MOVE N'WWI_InMemory_Data_1' TO N'C:\data\Data\WideWorldImporters_InMemory_Data_1'
	,  NOUNLOAD,  REPLACE,  STATS = 5

GO


