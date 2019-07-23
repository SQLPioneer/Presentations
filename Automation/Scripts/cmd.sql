/*
*/
declare @configure TABLE (name varchar(100), minimum int, maximum int, config_value int, run_value int)
INSERT INTO @configure EXEC sp_configure
if NOT EXISTS (SELECT * FROM @configure WHERE name = 'xp_cmdshell' AND config_value=0)
	BEGIN
		exec sp_configure 'show advanced options', '1'
		RECONFIGURE
		-- this enables xp_cmdshell
		exec sp_configure 'xp_cmdshell', '1' 
		RECONFIGURE
	END



--EXEC xp_cmdshell 'cd c:\data'
EXEC xp_cmdshell 'dir c:\'
EXEC xp_cmdshell 'dir c:\backup'
EXEC xp_cmdshell 'dir c:\data'

