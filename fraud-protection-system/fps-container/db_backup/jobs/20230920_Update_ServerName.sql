/*
	Created: 20230920@Sol
	Task: update server name in PerfMonDB db
	DB: 10.40.40.33,16401-PerfMonDB
*/

USE PerfMonDB;

GO

UPDATE vnDBA_FPS_BackupDatabases
	SET ServerName = @@SERVERNAME
WHERE ServerName = 'FPS_DB02\FPS_01'
GO